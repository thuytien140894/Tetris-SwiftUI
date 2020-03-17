//
//  GameManager.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/30/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI
import Combine

final class GameManager {
    
    @Binding private var board: Board
    @Binding private var tetrominoQueue: [Tetromino]
    @Binding private var savedTetromino: Tetromino?
    
    private let eventTrigger: AnyPublisher<Date, Never>
    private let tetrominoGenerator: () -> Tetromino
    private lazy var gameController = {
        makeGameController()
    }()
    
    private var tetromino = Tetromino() {
        didSet {
            tetromino.positionIsChanged = tetrominoPositionIsChanged
            tetrominoPositionIsChanged.send()
        }
    }
    private let tetrominoPositionIsChanged = PassthroughSubject<Void, Never>()
    private var cancellableSet = Set<AnyCancellable>()
    private var canSaveTetromino = true
    
    init(board: Binding<Board>,
         tetrominoQueue: Binding<[Tetromino]>,
         savedTetromino: Binding<Tetromino?>,
         eventTrigger: AnyPublisher<Date, Never>,
         tetrominoGenerator: @escaping () -> Tetromino) {
        
        self._board = board
        self._tetrominoQueue = tetrominoQueue
        self._savedTetromino = savedTetromino
        self.eventTrigger = eventTrigger
        self.tetrominoGenerator = tetrominoGenerator
        
        tetrominoPositionIsChanged
            .tryReceivingOnMainThread()
            .sink { [weak self] _ in
                self?.projectLockedPosition()
            }
            .store(in: &cancellableSet)
    }
    
    private func projectLockedPosition() {
        
        let lockedCoordinates = gameController.lock(coordinates: tetromino.coordinates)
        board.shadeCells(at: lockedCoordinates)
    }
    
    func startGame() {
        
        nextRound()
        
        eventTrigger
            .tryReceivingOnMainThread()
            .sink { [weak self] _ in
                self?.dropTetromino()
            }
            .store(in: &cancellableSet)
    }
    
    private func dropTetromino() {
        
        gameController.drop(coordinates: tetromino.coordinates)
    }
    
    private func makeGameController() -> GameController {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .tryReceivingOnMainThread()
            .sink { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .new(let oldCoordinates, let newCoordinates):
                    self.updateBoard(from: oldCoordinates, to: newCoordinates)
                case .locked:
                    self.nextRound()
                }
            }
            .store(in: &cancellableSet)
        
        return GameController(subject: subject, movementValidator: board.cellsAreOpen(at:))
    }
    
    private func updateBoard(from oldCoordinates: [Coordinate], to newCoordinates: [Coordinate]) {
        
        if Tetromino.compare(coordinates: tetromino.coordinates,
                             anotherCoordinates: oldCoordinates) {
            board.dehighlightCells(at: oldCoordinates)
            board.highlightCells(at: newCoordinates, using: tetromino.color)
            tetromino.coordinates = newCoordinates
        } else {
            board.moveHighlightedCells(from: oldCoordinates, to: newCoordinates)
        }
    }
    
    private func nextRound() {
        
        if board.tryLineClear() {
            let cellGroups = board.aggregateCellBlocks()
            cellGroups.forEach { cellGroup in
                let coordinates = cellGroup.map { $0.position }
                gameController.hardDrop(coordinates: coordinates)
            }
        }
        
        tetromino = nextTetromino()
        
        canSaveTetromino = true
    }
    
    private func nextTetromino() -> Tetromino {
        
        let nextTetromino = dequeueTetromino()
        nextTetromino.prepareInitialCoordinatesOnBoard()

        return nextTetromino
    }
    
    func moveTetrominoRight() {
        
        gameController.moveRight(coordinates: tetromino.coordinates)
    }
    
    func moveTetrominoLeft() {
        
        gameController.moveLeft(coordinates: tetromino.coordinates)
    }
    
    func rotateTetromino() {
        
        gameController.rotate(coordinates: tetromino.coordinates, within: tetromino.type.enclosedRegion)
    }
    
    func saveTetromino() {
        
        guard canSaveTetromino else { return }
        canSaveTetromino = false
        
        let currentTetromino = tetromino
        
        if let savedTetromino = savedTetromino {
            tetromino = Tetromino(type: savedTetromino.type, orientation: .one)
        } else {
            tetromino = dequeueTetromino()
        }
        
        let centerXPosition = Int(ceil(Double(board.columnCount) / 2))
        tetromino.adjustXPositionFromOrigin(by: centerXPosition - 1)
        savedTetromino = currentTetromino
        
        board.moveHighlightedCells(from: currentTetromino.coordinates,
                                   to: tetromino.coordinates,
                                   using: tetromino.color)
    }
    
    private func dequeueTetromino() -> Tetromino {
        
        var nextTetromino = Tetromino()

        if !tetrominoQueue.isEmpty {
            nextTetromino = tetrominoQueue[0]
            
            tetrominoQueue = Array(tetrominoQueue.dropFirst())
            let newTetromino = tetrominoGenerator()
            tetrominoQueue.append(newTetromino)
        }
        
        return nextTetromino
    }
    
    func reset() {
        
        board.clear()
        canSaveTetromino = true
    }

    func stopGame() {
        
        cancellableSet.forEach { $0.cancel() }
    }
}

extension Publisher {
    
    /// Returns a publisher that delivers elements on the main UI thread if
    /// the app is not running tests.
    func tryReceivingOnMainThread() -> AnyPublisher<Self.Output, Self.Failure> {
        
        let isUnitTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        guard !isUnitTesting else {
            return eraseToAnyPublisher()
        }
        
        return receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
