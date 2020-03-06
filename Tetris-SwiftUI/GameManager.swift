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
        
        tetromino = makeTetromino()
        
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
                case .new(let coordinates):
                    self.updateTetrominoPosition(to: coordinates)
                case .done:
                    self.tetromino = self.makeTetromino()
                default:
                    return
                }
            }
            .store(in: &cancellableSet)
        
        return GameController(subject: subject, movementValidator: areAvailable(coordinates:))
    }
    
    private func updateTetrominoPosition(to coordinates: [Coordinate]) {
        
        guard coordinates.count > 0 else { return }
        
        dehighlightBoard(at: tetromino.coordinates)
        tetromino.coordinates = coordinates
    }
    
    private func dehighlightBoard(at coordinates: [Coordinate]) {
        
        coordinates.forEach { coordinate in
            let cell = board.cell(atRow: coordinate.y, column: coordinate.x)
            cell?.isOpen = true
        }
    }
    
    private func makeTetromino() -> Tetromino {
        
        let tetromino = tetrominoGenerator()
        
        tetromino.$coordinates
            .receiveOnMainThreadIfPossible()
            .sink { [weak self] in
                guard let self = self else { return }
                self.highlightBoard(at: $0, color: tetromino.color)
            }
            .store(in: &cancellableSet)
        
        return tetromino
    }
    
    private func highlightBoard(at coordinates: [Coordinate], color: Color) {
        
        coordinates.forEach { coordinate in
            guard let cell = board.cell(atRow: coordinate.y, column: coordinate.x) else { return }
            cell.color = color
            cell.isOpen = false
        }
    }
    
    private func areAvailable(coordinates: [Coordinate]) -> Bool {
        
        for coordinate in coordinates {
            guard
                let cell = board.cell(atRow: coordinate.y, column: coordinate.x),
                cell.isOpen else {
                    
                    return false
            }
        }
        
        return true
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
