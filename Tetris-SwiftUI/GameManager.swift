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
    private var timerSubscriber: AnyCancellable? = nil

    func startGame(for board: Board) {
        
        self.board = board
        tetromino = makeTetromino()
        
        timerSubscriber = timerPublisher
            .autoconnect()
            .sink { [weak self] _ in
                self?.dropTetromino()
            }
    }
    
    private func makeTetromino() -> Tetromino {
        
        let type = TetrominoType.allCases.randomElement() ?? .i
        let orientation = Orientation.allCases.randomElement() ?? .one
        let color = Color(red: Double.random(in: 0...1),
                          green: Double.random(in: 0...1),
                          blue: Double.random(in: 0...1))
        
        var tetromino = Tetromino(type: type, orientation: orientation, color: color)
        let availableSpace = board.columnCount - tetromino.width
        tetromino.xPosition = Int.random(in: 0..<availableSpace)
        
        return tetromino
    }
    
    private func dropTetromino() {
    
        let newCoordinates = tetromino.coordinates.map { coordinate in
            (coordinate.x, coordinate.y + 1)
        }
        
        if canMoveTetromino(to: newCoordinates) {
            dehighlightBoard(at: tetromino.coordinates)
            highlightBoard(at: newCoordinates, color: tetromino.color)
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
            let cell = board.cell(atRow: coordinate.y, column: coordinate.x)
            cell?.color = color
            cell?.isOpen = false
        }
    }
    
    private func moveTetrominoRight() {
        
        
    }
    
    private func moveTetrominoLeft() {
        
        
    }
    
    private func rotateTetromino() {
        
        
    }
    
    func stopGame() {
        
        timerSubscriber?.cancel()
    }
}
