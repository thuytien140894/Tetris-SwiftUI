//
//  CellTests.swift
//  Tetris-SwiftUITests
//
//  Created by Tien Thuy Ho on 3/9/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import XCTest
import SwiftUI

@testable import Tetris_SwiftUI

class CellTests: XCTestCase {
    
    func testInitialization() {
        
        var cell = Cell(position: (0, 1))
        XCTAssert(cell.position == (0, 1))
        XCTAssert(cell.isOpen)
        XCTAssertEqual(cell.color, .clear)
        
        cell = Cell()
        XCTAssert(cell.position == (0, 0))
    }
}
