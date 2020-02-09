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
}
