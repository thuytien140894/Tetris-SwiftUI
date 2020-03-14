//
//  GameManager.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/30/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI
import Combine

class GameManager {
    
    @Binding private var board: Board
    
    private let eventTrigger: AnyPublisher<Date, Never>
    private let tetrominoGenerator: () -> Tetromino
    private lazy var gameController = {
        makeGameController()
    }()
    
    private var tetromino = Tetromino()

    private var cancellableSet = Set<AnyCancellable>()
    
    init(board: Binding<Board>,
         eventTrigger: AnyPublisher<Date, Never>,
         tetrominoGenerator: @escaping () -> Tetromino) {
        
        self._board = board
        self.eventTrigger = eventTrigger
        self.tetrominoGenerator = tetrominoGenerator
    }
    
    func startGame() {
        
        generateNewTetromino()
        
        eventTrigger
            .receiveOnMainThreadIfPossible()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.dropTetromino()
            }
            .store(in: &cancellableSet)
    }
    
    private func dropTetromino() {
        
        gameController.drop(coordinates: tetromino.coordinates)
    }
    
    private func makeGameController() -> GameController {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .receiveOnMainThreadIfPossible()
            .sink { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .new(let oldCoordinates, let newCoordinates):
                    if Tetromino.compare(coordinates: self.tetromino.coordinates,
                                         anotherCoordinates: oldCoordinates) {
                        self.tetromino.coordinates = newCoordinates
                    }
                    self.moveHighlightedCells(from: oldCoordinates, to: newCoordinates)
                case .done:
                    self.nextRound()
                }
            }
            .store(in: &cancellableSet)
        
        return GameController(subject: subject, movementValidator: board.cellsAreOpen(at:))
    }
    
    private func moveHighlightedCells(from currentCoordinates: [Coordinate],
                                      to newCoordinates: [Coordinate]) {
        
        guard currentCoordinates.count == newCoordinates.count else { return }
        
        /// Dehighlights the current cells and saves their colors to the new cells.
        zip(currentCoordinates, newCoordinates).forEach { (currentCoordinate, newCoordinate) in
            guard
                let currentCell = board.cell(atRow: currentCoordinate.y, column: currentCoordinate.x),
                let newCell = board.cell(atRow: newCoordinate.y, column: newCoordinate.x) else { return }
            
            let hasColor = (currentCell.color != .clear)
            newCell.color = hasColor ? currentCell.color : tetromino.color
            currentCell.isOpen = true
        }
        
        board.highlightCells(at: newCoordinates)
    }
    
    private func nextRound() {
        
        if board.tryLineClear() {
            let cellGroups = board.aggregateCellBlocks()
            cellGroups.forEach { cellGroup in
                let coordinates = cellGroup.map { $0.position }
                gameController.hardDrop(coordinates: coordinates)
            }
        }
        
        generateNewTetromino()
    }
    
    private func generateNewTetromino() {
        
        tetromino = tetrominoGenerator()
        board.highlightCells(at: tetromino.coordinates)
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
    
    func reset() {
        
        board.clear()
    }

    func stopGame() {
        
        cancellableSet.forEach { $0.cancel() }
    }
}

extension Publisher {
    
    /// Returns a publisher that delivers elements on the main UI thread if
    /// the app is not running tests.
    func receiveOnMainThreadIfPossible() -> AnyPublisher<Self.Output, Self.Failure> {
        
        let isUnitTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        guard !isUnitTesting else {
            return eraseToAnyPublisher()
        }
        
        return receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
