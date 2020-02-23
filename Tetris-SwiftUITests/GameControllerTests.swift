//
//  GameControllerTests.swift
//  Tetris-SwiftUITests
//
//  Created by Tien Thuy Ho on 2/16/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import XCTest
import Combine

@testable import Tetris_SwiftUI

class GameControllerTests: XCTestCase {
    
    private var cancellableSet = Set<AnyCancellable>()
    
    func testDroppingCoordinates() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .new([(0, 1)]))
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in true }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.drop(coordinates: [(0, 0)])
    }
    
    func testMovingCoordinatesRight() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .new([(1, 0)]))
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in true }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.moveRight(coordinates: [(0, 0)])
    }
    
    func testMovingCoordinatesLeft() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .new([(-1, 0)]))
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in true }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.moveLeft(coordinates: [(0, 0)])
    }
    
    func testRotatingCoordinates() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .new([(0, -1), (0, 0)]))
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in true }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.rotate(coordinates: [(0, 0), (1, 0)], within: [(0, 0), (1, -1)])
    }
    
    func testDroppingCoordinatesFails() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .done)
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in false }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.drop(coordinates: [(0, 0)])
    }
    
    func testMovingCoordinatesRightFails() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .notPossible)
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in false }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.moveRight(coordinates: [(0, 0)])
    }

    func testMovingCoordinatesLeftFails() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .notPossible)
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in false }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.moveLeft(coordinates: [(0, 0)])
    }
    
    func testRotatingCoordinatesRightFails() {
        
        let subject = PassthroughSubject<MovementResult, Never>()
        subject
            .sink {
                XCTAssertEqual($0, .notPossible)
            }
            .store(in: &cancellableSet)
            
        let validator: ([Coordinate]) -> Bool = { _ in false }
        let gameController = GameController(subject: subject, movementValidator: validator)
        gameController.rotate(coordinates: [(0, 0)])
    }
}
