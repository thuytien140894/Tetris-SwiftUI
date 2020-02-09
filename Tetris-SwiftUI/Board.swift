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
    
    /// Returns a cell at the specified row and column.
    /// Whereas the column index must be within bounds, the row
    /// index can be negative for tetrominos that have not
    /// descended into view. Therefore, we return a "dummy"
    /// cell to indicate validity.
    func cell(atRow row: Int, column: Int) -> Cell? {
        
        guard
            (0..<columnCount).contains(column),
            row < rowCount else { return nil }
        
        if row < 0 {
            return Cell()
        }
        
        return cells[row][column]
    }
    
    func clear() {
        
        cells.forEach {
            $0.forEach { $0.isOpen = true }
        }
    }
}
