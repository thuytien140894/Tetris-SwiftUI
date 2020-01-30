//
//  Board.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/27/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct Board {
    
    private(set) var cells: [[Cell]] = []
    let rowCount: Int
    let columnCount: Int
    
    init(rowCount: Int, columnCount: Int) {
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        
        for _ in 0..<rowCount {
            let row: [Cell] = (0..<columnCount).map { _ in Cell() }
            cells.append(row)
        }
    }
}
