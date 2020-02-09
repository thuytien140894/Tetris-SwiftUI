//
//  GameManagerTests.swift
//  Tetris-SwiftUITests
//
//  Created by Tien Thuy Ho on 2/8/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import XCTest
import Combine
import SwiftUI

@testable import Tetris_SwiftUI

class GameManagerTests: XCTestCase {
    
    private var board = Board(rowCount: 5, columnCount: 5)
    private let mockTimer = PassthroughSubject<Date, Never>()
    
    private lazy var gameManager: GameManager = {
        let boardBinding = Binding(
            get: { [weak self] in
                self?.board ?? Board()
            },
            set: { [weak self] in
                self?.board = $0
            }
        )
        return GameManager(board: boardBinding, eventTrigger: mockTimer.eraseToAnyPublisher())
    }()
    
    override func setUp() {
        
        super.setUp()
        
        gameManager.reset()
        gameManager.startGame()
    
        /// The tallest tetromino has an i shape and a
        /// vertical orientation. Therefore we drop the
        /// tetromino four times to make sure that any
        /// random tetromino would be entirely visible
        /// in the board.
        for _ in (0..<4) {
            mockTimer.send(Date())
        }
    }
    
    func testDroppingTetromino() throws {
        
        var cellIndices = highlightedCellIndices()
        XCTAssertFalse(cellIndices.isEmpty, "Board should highlight some cells.")
        
        mockTimer.send(Date())
        
        cellIndices = cellIndices.map { ($0.x, $0.y + 1) }
        try assertCellsAreNotOpen(at: cellIndices)
    }
    
    func testMovingTetrominoLeft() throws {
        
        var cellIndices = highlightedCellIndices()
        XCTAssertFalse(cellIndices.isEmpty, "Board should highlight some cells.")
        
        gameManager.moveTetrominoLeft()
        
        let leftEdgeCells = cellIndices.filter { $0.x == 0 }
        if leftEdgeCells.isEmpty {
            cellIndices = cellIndices.map { ($0.x - 1, $0.y) }
        }
        
        try assertCellsAreNotOpen(at: cellIndices)
    }
    
    func testMovingTetrominoRight() throws {
        
        var cellIndices = highlightedCellIndices()
        XCTAssertFalse(cellIndices.isEmpty, "Board should highlight some cells.")
        
        gameManager.moveTetrominoRight()
        
        let rightEdgeCells = cellIndices.filter { $0.x == board.columnCount - 1 }
        if rightEdgeCells.isEmpty {
            cellIndices = cellIndices.map { ($0.x + 1, $0.y) }
        }
        
        try assertCellsAreNotOpen(at: cellIndices)
    }
    
    func testRotatingTetromino() {}
    
    private func assertCellsAreNotOpen(at indices: [Coordinate]) throws {
        
        try indices.forEach { coordinate in
            let cell = try XCTUnwrap(board.cell(atRow: coordinate.y, column: coordinate.x), "A cell should exist.")
            XCTAssertFalse(cell.isOpen)
        }
    }
    
    private func highlightedCellIndices() -> [Coordinate] {
        
        var indices: [Coordinate] = []
        for (row, rowCells) in board.cells.enumerated() {
            for (column, cell) in rowCells.enumerated() {
                if !cell.isOpen {
                    indices.append((column, row))
                }
            }
        }
        
        return indices
    }
}
