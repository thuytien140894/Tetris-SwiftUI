//
//  Board.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/27/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct Board {
    
    let rowCount: Int
    let columnCount: Int
    let cells: [[Cell]]
    
    init() {
        
        self.init(rowCount: 0, columnCount: 0)
    }
    
    init(rowCount: Int, columnCount: Int) {
        
        self.rowCount = rowCount
        self.columnCount = columnCount
        
        var newCells: [[Cell]] = []
        for _ in 0..<rowCount {
            let row: [Cell] = (0..<columnCount).map { _ in Cell() }
            newCells.append(row)
        }
        cells = newCells
    }
    
    func cell(atRow row: Int, column: Int) -> Cell? {
        
        guard row >= 0 else { return Cell() }
        
        guard
            (0..<rowCount).contains(row) &&
            (0..<columnCount).contains(column) else { return nil }
        
        return cells[row][column]
    }
}
