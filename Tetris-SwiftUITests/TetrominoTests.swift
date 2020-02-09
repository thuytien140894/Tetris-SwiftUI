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
        XCTAssertEqual(rotatedWidth, 2)
        
        orientation = .two
        rotatedWidth = orientation.width(fromDimension: dimension)
        XCTAssertEqual(rotatedWidth, 1)
        
        orientation = .three
        rotatedWidth = orientation.width(fromDimension: dimension)
        XCTAssertEqual(rotatedWidth, 2)
        
        orientation = .four
        rotatedWidth = orientation.width(fromDimension: dimension)
        XCTAssertEqual(rotatedWidth, 1)
    }
    
    func testRotatingCoordinates() throws {
        
        let coordinate = (1, 1)
        let coordinates = [coordinate]
        
        var orientation: Orientation = .one
        var rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        var rotatedCoordinate = try XCTUnwrap(rotatedCoordinates.first, "A coordinate should exist.")
        XCTAssert(rotatedCoordinate == (1, 1))
        
        orientation = .two
        rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        rotatedCoordinate = try XCTUnwrap(rotatedCoordinates.first, "A coordinate should exist.")
        XCTAssert(rotatedCoordinate == (-1, 1))
        
        orientation = .three
        rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        rotatedCoordinate = try XCTUnwrap(rotatedCoordinates.first, "A coordinate should exist.")
        XCTAssert(rotatedCoordinate == (-1, -1))
        
        orientation = .four
        rotatedCoordinates = orientation.rotate(coordinates: coordinates)
        rotatedCoordinate = try XCTUnwrap(rotatedCoordinates.first, "A coordinate should exist.")
        XCTAssert(rotatedCoordinate == (1, -1))
    }
    
    func testTetrominoCoordinates() {
        
        let tetromino = Tetromino(type: .l, orientation: .two, color: Color.red)
        
        var expectedCoordinates = [(1, -1), (1, -2), (1, -3), (0, -3)]
        for (coordinate, expectedCoordinate) in zip(tetromino.coordinates, expectedCoordinates) {
            XCTAssert(coordinate == expectedCoordinate)
        }
        
        tetromino.xPosition = 1
        expectedCoordinates = [(2, -1), (2, -2), (2, -3), (1, -3)]
        for (coordinate, expectedCoordinate) in zip(tetromino.coordinates, expectedCoordinates) {
            XCTAssert(coordinate == expectedCoordinate)
        }
    }
}
