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
    
    private var tetromino = Tetromino()
    private var board = Board()
    private let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    private var cancellableSet = Set<AnyCancellable>()

    func startGame(for board: Board) {
        
        self.board = board
        tetromino = makeTetromino()

        startTimer()
    }
    
    private func startTimer() {
        
        timerPublisher
            .autoconnect()
            .receive(on: RunLoop.main)
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
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.highlightBoard(at: $0, color: self.tetromino.color)
            }
            .store(in: &cancellableSet)
        
        return tetromino
    }
    
    private func dropTetromino() {
    
        let newCoordinates = tetromino.coordinates.map { coordinate in
            (coordinate.x, coordinate.y + 1)
        }
        
        if canMoveTetromino(to: newCoordinates) {
            dehighlightBoard(at: tetromino.coordinates)
            tetromino.coordinates = newCoordinates
        } else {
            tetromino = makeTetromino()
        }
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
    
    func moveTetrominoRight() {}
    
    func moveTetrominoLeft() {}
    
    func rotateTetromino() {}
}
