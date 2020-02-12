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
    
    private lazy var tetromino = {
        makeTetromino()
    }()
    
    private var cancellableSet = Set<AnyCancellable>()
    
    init(board: Binding<Board>, eventTrigger: AnyPublisher<Date, Never>) {
        
        self._board = board
        self.eventTrigger = eventTrigger
    }
    
    func startGame() {
        
        eventTrigger
            .receiveOnMainThreadIfPossible()
            .sink { [weak self] _ in
                self?.dropTetromino()
            }
            .store(in: &cancellableSet)
    }
    
    private func makeTetromino() -> Tetromino {
        
        let type = TetrominoType.allCases.randomElement() ?? .i
        let orientation = Orientation.allCases.randomElement() ?? .one
        let color = Color(red: Double.random(in: 0.2...1),
                          green: Double.random(in: 0.2...1),
                          blue: Double.random(in: 0.2...1))
        
        let tetromino = Tetromino(type: type, orientation: orientation, color: color)
        let availableSpace = board.columnCount - tetromino.width
        tetromino.xPosition = Int.random(in: 0..<availableSpace)
        
        tetromino.$coordinates
            .receiveOnMainThreadIfPossible()
            .sink { [weak self] in
                guard let self = self else { return }
                self.highlightBoard(at: $0, color: tetromino.color)
            }
            .store(in: &cancellableSet)
        
        return tetromino
    }
    
    private func dropTetromino() {
    
        let newCoordinates = tetromino.coordinates.map { coordinate in
            (coordinate.x, coordinate.y + 1)
        }
        
        updateTetrominoPosition(to: newCoordinates) { [weak self] in
            guard let self = self else { return }
            self.tetromino = self.makeTetromino()
        }
    }
    
    private func dehighlightBoard(at coordinates: [Coordinate]) {
        
        coordinates.forEach { coordinate in
            let cell = board.cell(atRow: coordinate.y, column: coordinate.x)
            cell?.isOpen = true
        }
    }
    
    private func highlightBoard(at coordinates: [Coordinate], color: Color) {
        
        coordinates.forEach { coordinate in
            guard let cell = board.cell(atRow: coordinate.y, column: coordinate.x) else { return }
            cell.color = color
            cell.isOpen = false
        }
    }
    
    func moveTetrominoRight() {
        
        let newCoordinates = tetromino.coordinates.map { coordinate in
            (coordinate.x + 1, coordinate.y)
        }
        
        updateTetrominoPosition(to: newCoordinates)
    }
    
    func moveTetrominoLeft() {
        
        let newCoordinates = tetromino.coordinates.map { coordinate in
            (coordinate.x - 1, coordinate.y)
        }
        
        updateTetrominoPosition(to: newCoordinates)
    }
    
    func rotateTetromino() {
        
        let newOrientation = tetromino.orientation.next()
        let newCoordinates = newOrientation.rotate(coordinates: tetromino.coordinates)
        
        updateTetrominoPosition(to: newCoordinates)
    }
    
    private func updateTetrominoPosition(to coordinates: [Coordinate], failureHandler: (() -> Void)? = nil) {
        
        guard canMoveTetromino(to: coordinates) else {
            failureHandler?()
            return
        }
        
        dehighlightBoard(at: tetromino.coordinates)
        tetromino.coordinates = coordinates
    }
    
    private func canMoveTetromino(to coordinates: [Coordinate]) -> Bool {
        
        let newCoordinates = coordinates.filter { !tetromino.contains(coordinate: $0) }
        
        for coordinate in newCoordinates {
            guard
                let cell = board.cell(atRow: coordinate.y, column: coordinate.x),
                cell.isOpen else {
                    
                    return false
            }
        }
        
        return true
    }
    
    func reset() {
        
        board.clear()
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
