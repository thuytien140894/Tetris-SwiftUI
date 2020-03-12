//
//  BoardTests.swift
//  Tetris-SwiftUITests
//
//  Created by Tien Thuy Ho on 2/9/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import XCTest

@testable import Tetris_SwiftUI

class BoardTests: XCTestCase {

    func testInitialization() {
        
        let board = Board(rowCount: 2, columnCount: 2)
        XCTAssertEqual(board.cells.count, 2)
        XCTAssertEqual(board.cells[0].count, 2)
    }
    
    func testIndexingCells() {
        
        let board = Board(rowCount: 2, columnCount: 2)
        
        // Invalid column
        var cell = board.cell(atRow: 0, column: -1)
        XCTAssertNil(cell)
        
        cell = board.cell(atRow: 0, column: 2)
        XCTAssertNil(cell)
        
        // Invalid row
        cell = board.cell(atRow: 2, column: 0)
        XCTAssertNil(cell)
        
        // "Valid" index for non-visible cells
        cell = board.cell(atRow: -1, column: 0)
        XCTAssertNotNil(cell)
        
        // Valid index
        cell = board.cell(atRow: 1, column: 0)
        XCTAssertNotNil(cell)
    }
    
    func testClearingBoard() {
        
        let board = Board(rowCount: 1, columnCount: 1)
        let cell = board.cells[0][0]
        cell.isOpen = false
        
        board.clear()
        XCTAssert(cell.isOpen)
    }
    
    func testLineClear() {
        
        let board = Board(rowCount: 1, columnCount: 5)
        let cells = board.cells[0]
        cells.forEach { $0.isOpen = false }
        
        XCTAssert(board.tryLineClear())
        cells.forEach {
            XCTAssert($0.isOpen)
        }
    }
    
    func testAggregatingCellBlocks() {
        
        let board = Board(rowCount: 5, columnCount: 5)
        let cells = board.cells
        
        /// 1. Group 1
        cells[2][0].isOpen = false
        
        /// 2. Group 2
        cells[1][3].isOpen = false
        cells[1][4].isOpen = false
        cells[2][3].isOpen = false
        cells[2][4].isOpen = false
        
        /// 3. Group 3
        cells[4][1].isOpen = false
        cells[4][2].isOpen = false
        cells[4][3].isOpen = false
        cells[4][4].isOpen = false
        
        let cellGroups = board.aggregateCellBlocks()
        XCTAssertEqual(cellGroups.count, 3)
        
        XCTAssertEqual(cellGroups[0].count, 4)
        XCTAssertEqual(cellGroups[1].count, 1)
        XCTAssertEqual(cellGroups[2].count, 4)
    }
    
    func testHighlightingCells() {
        
        let board = Board(rowCount: 2, columnCount: 2)
        let coordinates: [Coordinate] = [(0, 0), (1, 1)]
        board.highlightCells(at: coordinates)
        
        coordinates.forEach { coordinate in
            guard let cell = board.cell(atRow: coordinate.y, column: coordinate.x) else {
                return XCTFail("Cell should exist.")
            }
            XCTAssertFalse(cell.isOpen)
        }
    }
    
    func testCellsAreOpen() {
        
        let board = Board(rowCount: 3, columnCount: 3)
        board.cells[0][1].isOpen = false
        
        XCTAssert(board.cellsAreOpen(at: [(0, 0), (0, 1)]))
        XCTAssertFalse(board.cellsAreOpen(at: [(0, 0), (1, 0)]))
    }
}
