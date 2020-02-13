//
//  TetrominoTests.swift
//  Tetris-SwiftUITests
//
//  Created by Tien Thuy Ho on 1/26/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import XCTest
import SwiftUI

@testable import Tetris_SwiftUI

class TetrominoTests: XCTestCase {

    func testWidthOfDifferentOrientations() {
        
        let dimension = (width: 1, height: 2)
        
        var orientation: Orientation = .one
        var rotatedWidth = orientation.width(fromDimension: dimension)
        XCTAssertEqual(rotatedWidth, 1)
        
        orientation = .two
        rotatedWidth = orientation.width(fromDimension: dimension)
        XCTAssertEqual(rotatedWidth, 2)
        
        orientation = .three
        rotatedWidth = orientation.width(fromDimension: dimension)
        XCTAssertEqual(rotatedWidth, 1)
        
        orientation = .four
        rotatedWidth = orientation.width(fromDimension: dimension)
        XCTAssertEqual(rotatedWidth, 2)
    }
    
    func testRotatingCoordinates() {
        
        let coordinates = [(1, -1), (2, -1)]
        
        var orientation: Orientation = .one
        var rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        var expectedCoordinates = [(1, -1), (2, -1)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        orientation = .two
        rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        expectedCoordinates = [(1, -1), (1, -2)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        orientation = .three
        rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        expectedCoordinates = [(1, -1), (0, -1)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        orientation = .four
        rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        expectedCoordinates = [(1, -1), (1, 0)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
    }
    
    func testTetrominoCoordinates() {
        
        let tetromino = Tetromino(type: .l, orientation: .two, color: Color.red)
        
        var expectedCoordinates = [(1, -1), (1, -2), (1, -3), (0, -3)]
        XCTAssert(Tetromino.compare(coordinates: tetromino.coordinates, anotherCoordinates: expectedCoordinates))
        
        tetromino.xPosition = 1
        expectedCoordinates = [(2, -1), (2, -2), (2, -3), (1, -3)]
        XCTAssert(Tetromino.compare(coordinates: tetromino.coordinates, anotherCoordinates: expectedCoordinates))
    }
    
    func testComparingCoordinates() {
        
        XCTAssert(Tetromino.compare(coordinates: [(0, 1)], anotherCoordinates: [(0, 1)]))
        XCTAssertFalse(Tetromino.compare(coordinates: [(0, 1)], anotherCoordinates: [(1, 1)]))
    }
}
