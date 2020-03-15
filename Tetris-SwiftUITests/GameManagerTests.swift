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
    private var savedTetromino: Tetromino?
    
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
        
        let savedTetrominoBinding = Binding(
            get: { [weak self] in
                self?.savedTetromino
            },
            set: { [weak self] in
                self?.savedTetromino = $0
            }
        )
        
        let tetrominoGenerator = { Tetromino() }
        return GameManager(board: boardBinding,
                           tetrominoQueue: queueBinding,
                           savedTetromino: savedTetrominoBinding,
                           eventTrigger: mockTimer.eraseToAnyPublisher(),
                           tetrominoGenerator: tetrominoGenerator)
    }()
    
    override func setUp() {
        
        super.setUp()
        
        tetrominoQueue = [tetromino]
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
                                  savedTetromino: .constant(nil), 
                                  eventTrigger: mockTimer.eraseToAnyPublisher(),
                                  tetrominoGenerator: tetrominoGenerator)
        
        manager.startGame()
        
        /// Locks the current tetromino.
        tetromino.coordinates = [(0, 2), (0, 3), (1, 3), (1, 2)]
        tetrominoIsGenerated = false
        
        mockTimer.send(Date())
        
        XCTAssert(tetrominoIsGenerated)
        XCTAssertEqual(tetrominoQueue.count, 1)
        XCTAssert(tetrominoQueue.first === newTetromino)
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
        
        gameManager.startGame()
        let initialCoordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        tetromino.coordinates = initialCoordinates
        board.highlightCells(at: tetromino.coordinates)
        
        /// Highlights one cell to the right of the current
        /// tetromino to block its movement.
        let cell = board.cell(at: (2, 0))
        cell?.isOpen = false
        
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
        tetromino.coordinates = [(0, 1), (1, 1), (0, 2), (1, 2)]
        board.highlightCells(at: tetromino.coordinates)
        
        mockTimer.send(Date())
        
        /// The last two rows should be cleared, and the tetromino
        /// should hard drop. 
        let lastSecondRowCoordinates = board.cells[lastSecondRow].map { $0.position }
        try assertCells(areOpen: true, at: lastSecondRowCoordinates + [(2, 3), (3, 3)])
        try assertCells(areOpen: false, at: [(0, 3), (1, 3)])
    }
    
    func testSavingFirstTetromino() throws {
        
        savedTetromino = nil
        
        let firstTetromino = Tetromino(type: .i, orientation: .one)
        let secondTetromino = Tetromino(type: .o, orientation: .one)
        tetrominoQueue = [firstTetromino, secondTetromino]
        
        gameManager.startGame()
        firstTetromino.coordinates = [(0, 0), (1, 0), (2, 0), (3, 0)]
        
        gameManager.saveTetromino()
        XCTAssert(savedTetromino === firstTetromino)
        
        /// Since there is no currently saved tetromino, the current
        /// tetromino is replaced by the next one in queue. This
        /// tetromino's coordinates should be adjusted accordingly.
        XCTAssert(Tetromino.compare(coordinates: secondTetromino.coordinates,
                                    anotherCoordinates: [(1, 0), (1, 1), (2, 1), (2, 0)]))
        try assertCells(areOpen: true, at: [(0, 0), (3, 0)])
        try assertCells(areOpen: false, at: secondTetromino.coordinates)
    }
    
    func testSavingAnotherTetromino() throws {
        
        savedTetromino = Tetromino(type: .s, orientation: .one)
        
        gameManager.startGame()
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        
        XCTAssertEqual(tetrominoQueue.count, 1)
        let queuedTetromino = try XCTUnwrap(tetrominoQueue.first, "One tetromino should be enqueued.")
        
        gameManager.saveTetromino()
        XCTAssert(savedTetromino === tetromino)
        
        /// The current tetromino is swapped with the saved
        /// tetromnino. Hence the next tetromino should
        /// still remain in the queue.
        XCTAssertEqual(tetrominoQueue.count, 1)
        XCTAssert(tetrominoQueue.first === queuedTetromino)
        
        try assertCells(areOpen: true, at: [(0, 0), (0, 1), (1, 0)])
        
        /// Cells for a T-shaped tetromino should be highlighted
        /// to indicate that the current tetromino has been
        /// swapped correctly.
        try assertCells(areOpen: false, at: [(1, 1), (2, 1), (2, 0), (3, 0)])
    }
    
    func testSavingTetrominoIsDisabled() {
        
        savedTetromino = nil
        
        let firstTetromino = Tetromino(type: .i, orientation: .one)
        let secondTetromino = Tetromino(type: .o, orientation: .one)
        let thirdTetromino = Tetromino(type: .t, orientation: .one)
        tetrominoQueue = [firstTetromino, secondTetromino, thirdTetromino]
        
        gameManager.startGame()
        
        gameManager.saveTetromino()
        XCTAssert(savedTetromino === firstTetromino)
        
        /// Saving a tetromino is disabled immediately
        /// after a save.
        gameManager.saveTetromino()
        XCTAssert(savedTetromino === firstTetromino)
        
        /// The current tetromino should be replaced with
        /// the second tetromino in the queue. We lock
        /// its coordinates.
        secondTetromino.coordinates = [(0, 2), (0, 3), (1, 2), (1, 3)]
        mockTimer.send(Date())
         
        /// Since the tetromino is locked, the next round
        /// starts to dequeue the next tetromino.
        /// Saving tetromino should be enabled again.
        gameManager.saveTetromino()
        XCTAssert(savedTetromino === thirdTetromino)
    }
    
    private func assertCells(areOpen: Bool, at indices: [Coordinate]) throws {
        
        try indices.forEach { coordinate in
            let cell = try XCTUnwrap(board.cell(at: coordinate), "A cell should exist.")
            areOpen ? XCTAssert(cell.isOpen) : XCTAssertFalse(cell.isOpen)
        }
    }
}
