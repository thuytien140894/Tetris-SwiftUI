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
    
    private var board = Board(rowCount: 4, columnCount: 4)
    private lazy var tetrominoQueue = {
        [tetromino]
    }()
    
    private let mockTimer = PassthroughSubject<Date, Never>()
    private var tetromino = Tetromino(type: .o, orientation: .one)
    
    private lazy var gameManager: GameManager = {
        let boardBinding = Binding(
            get: { [weak self] in
                self?.board ?? Board()
            },
            set: { [weak self] in
                self?.board = $0
            }
        )
        
        let queueBinding = Binding(
            get: { [weak self] in
                self?.tetrominoQueue ?? []
            },
            set: { [weak self] in
                self?.tetrominoQueue = $0
            }
        )
        
        let tetrominoGenerator = { Tetromino() }
        return GameManager(board: boardBinding,
                           tetrominoQueue: queueBinding,
                           eventTrigger: mockTimer.eraseToAnyPublisher(),
                           tetrominoGenerator: tetrominoGenerator)
    }()
    
    override func setUp() {
        
        super.setUp()
        
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        
        gameManager.reset()
        gameManager.stopGame()
    }
    
    func testDroppingTetromino() throws {

        gameManager.startGame()
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        
        /// Sends a value through the timer to prompt the tetromino
        /// to drop.
        mockTimer.send(Date())

        try assertCells(areOpen: true, at: [(0, 0), (1, 0)])
        let cellIndices = [(0, 1), (0, 2), (1, 2), (1, 1)]
        try assertCells(areOpen: false, at: cellIndices)
    }
    
    func testNewTetrominoIsGeneratedAndEnqueuedWhenDroppingFails() {
        
        let queueBinding = Binding(
            get: { [weak self] in
                self?.tetrominoQueue ?? []
            },
            set: { [weak self] in
                self?.tetrominoQueue = $0
            }
        )
        
        var tetrominoIsGenerated = false
        let newTetromino = Tetromino()
        let tetrominoGenerator: () -> Tetromino = {
            tetrominoIsGenerated = true
            return newTetromino
        }
        
        let manager = GameManager(board: .constant(board),
                                  tetrominoQueue: queueBinding,
                                  eventTrigger: mockTimer.eraseToAnyPublisher(),
                                  tetrominoGenerator: tetrominoGenerator)
        
        let cell = board.cell(atRow: 2, column: 0)
        cell?.isOpen = false
        
        /// Starting a game generates a new tetromino; thus
        /// we need to reset the variable before testing.
        manager.startGame()
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        tetrominoIsGenerated = false
        
        mockTimer.send(Date())
        
        XCTAssert(tetrominoIsGenerated)
        XCTAssertEqual(tetrominoQueue.count, 1)
        XCTAssert(tetrominoQueue[0] === newTetromino)
    }

    func testMovingTetrominoLeft() throws {

        gameManager.startGame()
        tetromino.coordinates = [(1, 0), (1, 1), (2, 1), (2, 0)]
        
        gameManager.moveTetrominoLeft()

        try assertCells(areOpen: true, at: [(2, 0), (2, 1)])
        let cellIndices = [(0, 0), (0, 1), (1, 1), (1, 0)]
        try assertCells(areOpen: false, at: cellIndices)
    }

    func testMovingTetrominoRight() throws {

        gameManager.startGame()
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        
        gameManager.moveTetrominoRight()

        try assertCells(areOpen: true, at: [(0, 0), (0, 1)])
        let cellIndices = [(1, 0), (1, 1), (2, 1), (2, 0)]
        try assertCells(areOpen: false, at: cellIndices)
    }

    func testRotatingTetromino() throws {

        tetromino = Tetromino(type: .i, orientation: .one)
        tetrominoQueue = [tetromino]
        
        gameManager.startGame()
        tetromino.coordinates = [(1, 0), (1, 1), (1, 2), (1, 3)]
        board.highlightCells(at: tetromino.coordinates)
        
        gameManager.rotateTetromino()

        try assertCells(areOpen: true, at: [(1, 0), (1, 1), (1, 3)])
        let cellIndices = [(0, 2), (1, 2), (2, 2), (3, 2)]
        try assertCells(areOpen: false, at: cellIndices)
    }
    
    func testMovingTetrominoShouldFail() throws {

        let cell = board.cell(atRow: 0, column: 2)
        cell?.isOpen = false
        
        gameManager.startGame()
        let initialCoordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        tetromino.coordinates = initialCoordinates
        board.highlightCells(at: tetromino.coordinates)
        
        gameManager.moveTetrominoRight()
        
        try assertCells(areOpen: true, at: [(2, 1)])
        try assertCells(areOpen: false, at: initialCoordinates)
    }
    
    func testLineClear() throws {
        
        /// Fills the last two rows.
        let lastSecondRow = board.rowCount - 2
        board.cells[lastSecondRow].forEach { $0.isOpen = false }
        
        let lastRow = board.rowCount - 1
        board.cells[lastRow].forEach { $0.isOpen = false }
        
        gameManager.startGame()
        tetromino.coordinates = [(0, 1), (1, 1), (2, 1)]
        board.highlightCells(at: tetromino.coordinates)
        
        mockTimer.send(Date())
        
        let lastSecondRowCoordinates = board.cells[lastSecondRow].map { $0.position }
        try assertCells(areOpen: true, at: lastSecondRowCoordinates + [(3, 3)])
        try assertCells(areOpen: false, at: [(0, 3), (1, 3), (2, 3)])
    }
    
    private func assertCells(areOpen: Bool, at indices: [Coordinate]) throws {
        
        try indices.forEach { coordinate in
            let cell = try XCTUnwrap(board.cell(atRow: coordinate.y, column: coordinate.x), "A cell should exist.")
            areOpen ? XCTAssert(cell.isOpen) : XCTAssertFalse(cell.isOpen)
        }
    }
}
