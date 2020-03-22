//
//  ScoreCalculatorTests.swift
//  Tetris-SwiftUITests
//
//  Created by Tien Thuy Ho on 3/22/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import XCTest

@testable import Tetris_SwiftUI

final class ScoreCalculatorTests: XCTestCase {
    
    func testCalculatingScoreForLineClear() {
        
        let scoreCalculator = ScoreCalculator()
        
        scoreCalculator.linesAreCleared(count: 1, usingHardDrop: false)
        XCTAssertEqual(scoreCalculator.score, 40)
        
        scoreCalculator.reset()
        scoreCalculator.linesAreCleared(count: 2, usingHardDrop: false)
        XCTAssertEqual(scoreCalculator.score, 100)
        
        scoreCalculator.reset()
        scoreCalculator.linesAreCleared(count: 3, usingHardDrop: false)
        XCTAssertEqual(scoreCalculator.score, 300)
        
        scoreCalculator.reset()
        scoreCalculator.linesAreCleared(count: 4, usingHardDrop: false)
        XCTAssertEqual(scoreCalculator.score, 1200)
        
        scoreCalculator.reset()
        scoreCalculator.linesAreCleared(count: 5, usingHardDrop: false)
        XCTAssertEqual(scoreCalculator.score, 0)
    }
    
    func testCalculatingScoreForHardDropLineClear() {
        
        let scoreCalculator = ScoreCalculator()
        scoreCalculator.linesAreCleared(count: 1, usingHardDrop: true)
        
        XCTAssertEqual(scoreCalculator.score, 42)
    }
    
    func testResetingScore() {
        
        let scoreCalculator = ScoreCalculator()
        scoreCalculator.score = 10
        
        scoreCalculator.reset()
        XCTAssertEqual(scoreCalculator.score, 0)
    }
}
