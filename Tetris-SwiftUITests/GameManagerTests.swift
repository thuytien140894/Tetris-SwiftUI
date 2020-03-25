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

final class GameManagerTests: XCTestCase {
    
    private var board = Board(rowCount: 4, columnCount: 4)
    private lazy var tetrominoQueue = {
        [tetromino]
    }()
    private var savedTetromino: Tetromino?
    
    private let mockTimer = PassthroughSubject<Date, Never>()
    private var tetromino = Tetromino(type: .o, orientation: .one)
    private let scoreCalculator = ScoreCalculator()
    
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
        
        return GameManager(board: boardBinding,
                           tetrominoQueue: queueBinding,
                           savedTetromino: savedTetrominoBinding,
                           eventTrigger: { self.mockTimer.eraseToAnyPublisher() },
                           scoreCalculator: scoreCalculator,
                           tetrominoGenerator: { Tetromino() })
    }()
    
    override func setUp() {
        
        super.setUp()
        
        tetrominoQueue = [tetromino]
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
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
                                  eventTrigger: { self.mockTimer.eraseToAnyPublisher() },
                                  scoreCalculator: scoreCalculator,
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
    
    func testHardDroppingTetromino() throws {
        
        gameManager.startGame()
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        
        gameManager.hardDropTetromino()
        try assertCells(areOpen: true, at: [(0, 0), (0, 1), (1, 1), (1, 0)])
        let cellIndices = [(0, 2), (0, 3), (1, 3), (1, 2)]
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
        
        gameManager.startGame()
        
        /// Fills the last two rows.
        let lastSecondRow = board.rowCount - 2
        board.cells[lastSecondRow].forEach { $0.isOpen = false }
        
        let lastRow = board.rowCount - 1
        board.cells[lastRow].forEach { $0.isOpen = false }
        
        tetromino.coordinates = [(0, 1), (1, 1), (0, 2), (1, 2)]
        board.highlightCells(at: tetromino.coordinates)
        
        mockTimer.send(Date())
        
        /// The last two rows should be cleared, and the tetromino
        /// should hard drop. 
        let lastSecondRowCoordinates = board.cells[lastSecondRow].map { $0.position }
        try assertCells(areOpen: true, at: lastSecondRowCoordinates + [(2, 3), (3, 3)])
        try assertCells(areOpen: false, at: [(0, 3), (1, 3)])
        
        XCTAssertEqual(scoreCalculator.score, 100)
    }
    
    func testLineClearWithHardDrop() {
        
        let firstTetromino = Tetromino(type: .o, orientation: .one)
        let secondTetromino = Tetromino(type: .o, orientation: .one)
        tetrominoQueue = [firstTetromino, secondTetromino]
        
        gameManager.startGame()
        
        /// Line clear with hard drop.
        let lastRow = board.rowCount - 1
        board.cells[lastRow].forEach { $0.isOpen = false }
        
        firstTetromino.coordinates = [(0, 0), (1, 0), (0, 1), (1, 1)]
        gameManager.hardDropTetromino()
        
        /// Triggers next round since the current tetromino is locked.
        mockTimer.send(Date())
        XCTAssertEqual(scoreCalculator.score, 42)
        
        /// Line clear without hard drop.
        scoreCalculator.reset()
        board.cells[lastRow].forEach { $0.isOpen = false }
        secondTetromino.coordinates = [(0, 1), (1, 1), (0, 2), (1, 2)]
        mockTimer.send(Date())
        
        /// Hard drop flag should be reset for each round
        /// and score is calculated accordingly.
        XCTAssertEqual(scoreCalculator.score, 40)
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
        
        gameManager.startGame()
        
        savedTetromino = Tetromino(type: .s, orientation: .one)
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
    
    func testPausingGame() throws {

        gameManager.startGame()
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        
        mockTimer.send(Date())

        /// Tetromino gets dropped in response to the timer being fired.
        try assertCells(areOpen: true, at: [(0, 0), (1, 0)])
        let cellIndices = [(0, 1), (0, 2), (1, 2), (1, 1)]
        try assertCells(areOpen: false, at: cellIndices)
        
        gameManager.pauseGame()
        mockTimer.send(Date())
        
        /// Tetromino doesn't get dropped because timer subscription is cancelled. 
        try assertCells(areOpen: false, at: cellIndices)
        try assertCells(areOpen: true, at: [(0, 3), (1, 3)])
    }
    
    private func assertCells(areOpen: Bool, at indices: [Coordinate]) throws {
        
        try indices.forEach { coordinate in
            let cell = try XCTUnwrap(board.cell(at: coordinate), "A cell should exist.")
            areOpen ? XCTAssert(cell.isOpen) : XCTAssertFalse(cell.isOpen)
        }
    }
    
    func testProjectingLockedPosition() {

        let boardBinding = Binding(
            get: { [weak self] in
                self?.board ?? Board()
            },
            set: { [weak self] in
                self?.board = $0
            }
        )

        let manager = GameManager(board: boardBinding,
                                  tetrominoQueue: .constant(tetrominoQueue),
                                  savedTetromino: .constant(savedTetromino),
                                  eventTrigger: { self.mockTimer.eraseToAnyPublisher() },
                                  scoreCalculator: scoreCalculator,
                                  tetrominoGenerator: { Tetromino() })
        manager.startGame()
        
        tetromino.coordinates = [(0, 0), (0, 1), (1, 1), (1, 0)]
        let shadedCoordinates = [(0, 2), (0, 3), (1, 3), (1, 2)]
        shadedCoordinates.forEach { coordinate in
            guard let cell = board.cell(at: coordinate) else {
                return XCTFail("Cell should exist.")
            }
            XCTAssert(cell.isShaded)
        }
        
        tetromino.coordinates = [(2, 0), (2, 1), (3, 1), (3, 0)]
        let newShadedCoordinates = [(2, 2), (2, 3), (3, 3), (3, 2)]
        newShadedCoordinates.forEach { coordinate in
            guard let cell = board.cell(at: coordinate) else {
                return XCTFail("Cell should exist.")
            }
            XCTAssert(cell.isShaded)
        }
    }
    
    func testStartingGame() {
        
        scoreCalculator.score = 40
        board.cells[0][0].isOpen = false
        
        let firstTetromino = Tetromino(type: .i, orientation: .one)
        let secondTetromino = Tetromino(type: .o, orientation: .one)
        let thirdTetromino = Tetromino(type: .t, orientation: .one)
        tetrominoQueue = [firstTetromino, secondTetromino, thirdTetromino]
        
        gameManager.startGame()
        gameManager.saveTetromino()
        
        /// Saving should be disabled.
        gameManager.saveTetromino()
        XCTAssert(savedTetromino === firstTetromino)
        
        gameManager.startGame()
        
        /// Score, board, and hold queue should be reset.
        XCTAssertEqual(scoreCalculator.score, 0)
        XCTAssert(board.cells[0][0].isOpen)
        XCTAssertNil(savedTetromino)
        
        /// Saving is enabled again.
        gameManager.saveTetromino()
        XCTAssert(savedTetromino === thirdTetromino)
    }
    
    func testContinuingGame() {

        var eventTriggerIsCalled = false
        let eventTrigger: () -> AnyPublisher<Date, Never> = {
            eventTriggerIsCalled = true
            return PassthroughSubject<Date, Never>().eraseToAnyPublisher()
        }
        
        let manager = GameManager(board: .constant(board),
                                  tetrominoQueue: .constant(tetrominoQueue),
                                  savedTetromino: .constant(savedTetromino),
                                  eventTrigger: eventTrigger,
                                  scoreCalculator: scoreCalculator,
                                  tetrominoGenerator: { Tetromino() })
        manager.continueGame()
        XCTAssert(eventTriggerIsCalled)
    }
}
