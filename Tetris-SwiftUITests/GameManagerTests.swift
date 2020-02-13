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
    private let mockTimer = PassthroughSubject<Date, Never>()
    private let tetromino = Tetromino(type: .o, orientation: .one, color: .white)
    
    private lazy var gameManager: GameManager = {
        let boardBinding = Binding(
            get: { [weak self] in
                self?.board ?? Board()
            },
            set: { [weak self] in
                self?.board = $0
            }
        )
        
        let tetrominoGenerator = { [weak self] in
            self?.tetromino ?? Tetromino()
        }
        return GameManager(board: boardBinding, eventTrigger: mockTimer.eraseToAnyPublisher(), tetrominoGenerator: tetrominoGenerator)
    }()
    
    override func setUp() {
        
        super.setUp()
        
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        
        gameManager.reset()
        gameManager.stopGame()
    }
    
    func testChangingTetrominoCoordinatesUpdatesBoard() throws {
        
        gameManager.startGame()
        tetromino.coordinates = [(1, 0), (1, 1), (2, 1), (2, 0)]
        
        try assertCells(areOpen: false, at: tetromino.coordinates)
    }
    
    func testDroppingTetromino() throws {

        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        gameManager.startGame()
        
        /// Sends a value through the timer to prompt the tetromino
        /// to drop.
        mockTimer.send(Date())

        try assertCells(areOpen: true, at: [(0, 0), (1, 0)])
        let cellIndices = [(0, 1), (0, 2), (1, 2), (1, 1)]
        try assertCells(areOpen: false, at: cellIndices)
    }
    
    func testNewTetrominoIsGeneratedWhenDroppingFails() {
        
        var tetrominoIsGenerated = false
        let tetrominoGenerator: () -> Tetromino = {
            tetrominoIsGenerated = true
            return self.tetromino
        }
        let manager = GameManager(board: .constant(board), eventTrigger: mockTimer.eraseToAnyPublisher(), tetrominoGenerator: tetrominoGenerator)
        
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        let cell = board.cell(atRow: 2, column: 0)
        cell?.isOpen = false
        
        /// Starting a game generates a new tetromino; thus
        /// we need to reset the variable before testing.
        manager.startGame()
        tetrominoIsGenerated = false
        mockTimer.send(Date())
        
        XCTAssert(tetrominoIsGenerated)
    }

    func testMovingTetrominoLeft() throws {

        tetromino.coordinates = [(1, 0), (1, 1), (2, 1), (2, 0)]
        gameManager.startGame()
        
        gameManager.moveTetrominoLeft()

        try assertCells(areOpen: true, at: [(2, 0), (2, 1)])
        let cellIndices = [(0, 0), (0, 1), (1, 1), (1, 0)]
        try assertCells(areOpen: false, at: cellIndices)
    }

    func testMovingTetrominoRight() throws {

        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        gameManager.startGame()
        
        gameManager.moveTetrominoRight()

        try assertCells(areOpen: true, at: [(0, 0), (0, 1)])
        let cellIndices = [(1, 0), (1, 1), (2, 1), (2, 0)]
        try assertCells(areOpen: false, at: cellIndices)
    }

    func testRotatingTetromino() throws {

        tetromino.coordinates = [(2, 0), (2, 1), (3, 1), (3, 0)]
        gameManager.startGame()
        
        gameManager.rotateTetromino()

        try assertCells(areOpen: true, at: [(3, 1), (3, 0)])
        let cellIndices = [(1, 1), (2, 1), (2, 0), (1, 0)]
        try assertCells(areOpen: false, at: cellIndices)
    }
    
    func testMovingTetrominoShouldFail() throws {

        let initialCoordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        tetromino.coordinates = initialCoordinates
        let cell = board.cell(atRow: 0, column: 2)
        cell?.isOpen = false
        
        gameManager.startGame()
        gameManager.moveTetrominoRight()
        
        try assertCells(areOpen: true, at: [(2, 1)])
        try assertCells(areOpen: false, at: initialCoordinates)
    }
    
    private func assertCells(areOpen: Bool, at indices: [Coordinate]) throws {
        
        try indices.forEach { coordinate in
            let cell = try XCTUnwrap(board.cell(atRow: coordinate.y, column: coordinate.x), "A cell should exist.")
            areOpen ? XCTAssert(cell.isOpen) : XCTAssertFalse(cell.isOpen)
        }
    }
}
