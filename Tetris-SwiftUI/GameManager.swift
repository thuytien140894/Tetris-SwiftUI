//
//  GameManager.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/30/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct GameManager {
    
    private var board = Board()

    mutating func startGame(for board: Board) {
        
        self.board = board
        
        var tetromino = makeTetromino()
        tetromino.coordinates.forEach { coordinate in
            if board.isValidIndex(row: coordinate.y, column: coordinate.x) {
                let cell = board.cells[coordinate.y][coordinate.x]
                cell.color = tetromino.color
                cell.isOpen = false
            }
        }
    }
    
    private func makeTetromino() -> Tetromino {
        
        let type: TetrominoType = TetrominoType.allCases.randomElement() ?? .i
        let orientation: Orientation = Orientation.allCases.randomElement() ?? .one
        let color = Color.red
        
        var tetromino = Tetromino(type: type, orientation: orientation, color: color)
        let availableSpace = board.columnCount - tetromino.width
        tetromino.xPosition = Int.random(in: 0..<availableSpace)
        
        return tetromino
    }
}
