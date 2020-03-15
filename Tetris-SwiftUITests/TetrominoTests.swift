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

    func testTetrominoDimensions() {
        
        var tetromino = Tetromino(type: .i, orientation: .one)
        XCTAssertEqual(tetromino.width, 4)
        XCTAssertEqual(tetromino.height, 1)
        
        tetromino = Tetromino(type: .o, orientation: .one)
        XCTAssertEqual(tetromino.width, 2)
        XCTAssertEqual(tetromino.height, 2)
        
        tetromino = Tetromino(type: .t, orientation: .one)
        XCTAssertEqual(tetromino.width, 3)
        XCTAssertEqual(tetromino.height, 2)
        
        tetromino = Tetromino(type: .j, orientation: .one)
        XCTAssertEqual(tetromino.width, 3)
        XCTAssertEqual(tetromino.height, 2)
        
        tetromino = Tetromino(type: .l, orientation: .one)
        XCTAssertEqual(tetromino.width, 3)
        XCTAssertEqual(tetromino.height, 2)
        
        tetromino = Tetromino(type: .s, orientation: .one)
        XCTAssertEqual(tetromino.width, 3)
        XCTAssertEqual(tetromino.height, 2)
        
        tetromino = Tetromino(type: .z, orientation: .one)
        XCTAssertEqual(tetromino.width, 3)
        XCTAssertEqual(tetromino.height, 2)
    }
    
    func testCoordinatesOfDifferentRotations() {
        
        let coordinates = [(1, -1), (2, -1)]
        let enclosedRegion = [(0, 0), (1, -1)]
        
        var orientation: Orientation = .one
        var rotatedCoordinates = orientation.rotate(coordinates: coordinates, within: enclosedRegion)
        var expectedCoordinates = [(1, -1), (2, -1)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        orientation = .two
        rotatedCoordinates = orientation.rotate(coordinates: coordinates, within: enclosedRegion)
        expectedCoordinates = [(1, -1), (1, -2)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        orientation = .three
        rotatedCoordinates = orientation.rotate(coordinates: coordinates, within: enclosedRegion)
        expectedCoordinates = [(2, -1), (1, -1)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        orientation = .four
        rotatedCoordinates = orientation.rotate(coordinates: coordinates, within: enclosedRegion)
        expectedCoordinates = [(1, -2), (1, -1)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
    }
    
    func testRotatingCoordinates() {
        
        /// 1. minX is outside.
        var coordinates = [(5, 3), (4, 3), (3, 3), (2, 3)]
        var enclosedRegion = [(-1, 1), (2, -2)]
        var rotatedCoordinates = Orientation.four.rotate(coordinates: coordinates, within: enclosedRegion)
        var expectedCoordinates = [(3, 4), (3, 3), (3, 2), (3, 1)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        /// 2. maxY is outside.
        coordinates = [(3, 2), (3, 3), (3, 4), (3, 5)]
        rotatedCoordinates = Orientation.two.rotate(coordinates: coordinates, within: enclosedRegion)
        expectedCoordinates = [(2, 4), (3, 4), (4, 4), (5, 4)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        /// 3. maxX is outside.
        coordinates = [(2, 3), (3, 3), (4, 3), (5, 3)]
        enclosedRegion = [(-2, 1), (1, -2)]
        rotatedCoordinates = Orientation.four.rotate(coordinates: coordinates, within: enclosedRegion)
        expectedCoordinates = [(4, 1), (4, 2), (4, 3), (4, 4)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
        
        /// 4. minY is outside.
        coordinates = [(3, 5), (3, 4), (3, 3), (3, 2)]
        enclosedRegion = [(-1, 2), (2, -1)]
        rotatedCoordinates = Orientation.two.rotate(coordinates: coordinates, within: enclosedRegion)
        expectedCoordinates = [(5, 3), (4, 3), (3, 3), (2, 3)]
        XCTAssert(Tetromino.compare(coordinates: expectedCoordinates, anotherCoordinates: rotatedCoordinates))
    }
    
    func testTetrominoCoordinates() {
        
        let tetromino = Tetromino(type: .l, orientation: .two)
        
        var expectedCoordinates = [(1, 2), (1, 1), (1, 0), (0, 0)]
        XCTAssert(Tetromino.compare(coordinates: tetromino.coordinates, anotherCoordinates: expectedCoordinates))
        
        tetromino.adjustXPositionFromOrigin(by: 1)
        expectedCoordinates = [(2, 2), (2, 1), (2, 0), (1, 0)]
        XCTAssert(Tetromino.compare(coordinates: tetromino.coordinates, anotherCoordinates: expectedCoordinates))
        
        tetromino.adjustXPositionFromOrigin(by: 5)
        expectedCoordinates = [(6, 2), (6, 1), (6, 0), (5, 0)]
        XCTAssert(Tetromino.compare(coordinates: tetromino.coordinates, anotherCoordinates: expectedCoordinates))
    }
    
    func testInitialCoordinatesOnBoard() {
        
        let tetromino = Tetromino(type: .i, orientation: .two)
        var expectedCoordinates: [Coordinate] = [(1, 3), (1, 2), (1, 1), (1, 0)]
        XCTAssert(Tetromino.compare(coordinates: tetromino.coordinates, anotherCoordinates: expectedCoordinates))
        
        tetromino.prepareInitialCoordinatesOnBoard()
        expectedCoordinates = [(1, -1), (1, -2), (1, -3), (1, -4)]
        XCTAssert(Tetromino.compare(coordinates: tetromino.coordinates, anotherCoordinates: expectedCoordinates))
    }
    
    func testComparingCoordinates() {
        
        XCTAssert(Tetromino.compare(coordinates: [(0, 1)], anotherCoordinates: [(0, 1)]))
        XCTAssertFalse(Tetromino.compare(coordinates: [(0, 1)], anotherCoordinates: [(1, 1)]))
    }
}
