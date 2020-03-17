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
        (0..<rowCount).forEach { row in
            let rowCells: [Cell] = (0..<columnCount).map { column in
                Cell(position: (column, row))
            }
            newCells.append(rowCells)
        }
        cells = newCells
    }
    
    /// Returns a cell at the specified coordinate
    /// where x corresponds to the column index and
    /// y to the row index.
    /// Whereas the column index must be within bounds, the row
    /// index can be negative for tetrominos that have not
    /// descended into view. Therefore, we return a "dummy"
    /// cell to indicate validity.
    func cell(at coordinate: Coordinate) -> Cell? {
        
        let column = coordinate.x
        let row = coordinate.y
        
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
    
    /// Checks for any rows that are filled completely and
    /// clears it by marking their cells as open. 
    func tryLineClear() -> Bool {
        
        let rowsToClear = filledRows()
        guard !rowsToClear.isEmpty else {
            return false
        }
        
        rowsToClear.forEach { row in
            let rowCells = cells[row]
            rowCells.forEach { $0.isOpen = true }
        }
        
        return true
    }
    
    private func filledRows() -> [Int] {
        
        let rowIsFilled: (Int) -> Bool = { row in
            let rowCells = self.cells[row]
            let filledCells = rowCells.filter { !$0.isOpen }
            return filledCells.count == self.columnCount
        }
        
        let filledRows = (0..<rowCount).filter { rowIsFilled($0) }
        return filledRows
    }
    
    /// Collects all the connected cell blocks in the board using
    /// breadth-first search. Accordingly, any cells that are
    /// adjacent horizontally or vertically are grouped as one
    /// block.
    func aggregateCellBlocks() -> [[Cell]] {
        
        let filledCells: [Cell] = (0..<rowCount).flatMap { row in
            cells[row].filter { !$0.isOpen }
        }
        
        let cellIterators = filledCells.map { CellIterator(cell: $0) }
        let cellGroups: [[Cell]] = cellIterators.compactMap { cellIterator in
            guard !cellIterator.isVisited else {
                return nil
            }
            
            var group: [Cell] = []
            var stack: [CellIterator] = []
            stack.append(cellIterator)
            
            while !stack.isEmpty {
                /// 1. Visits the next cell in the stack.
                let currentCellIterator = stack[0]
                stack = Array(stack.dropFirst())
                currentCellIterator.isVisited = true
                group.append(currentCellIterator.cell)
                
                /// 2. Saves all the non-visited neighbor cells in the stack.
                let column = currentCellIterator.cell.position.x
                let row = currentCellIterator.cell.position.y
                let neighborCoordinates: [Coordinate] = [(column + 1, row),
                                                         (column - 1, row),
                                                         (column, row + 1),
                                                         (column, row - 1)]
                let neighborCellIterators: [CellIterator] = neighborCoordinates
                    .compactMap { coordinate in
                        guard
                            let cell = self.cell(at: coordinate),
                            let iterator = cellIterators.first(where: { $0.cell === cell }),
                            !iterator.isVisited,
                            !stack.contains(iterator) else {
                                
                                return nil
                        }
                        return iterator
                }
                
                stack.append(contentsOf: neighborCellIterators)
            }
            
            return group
        }
        
        return cellGroups
    }
    
    func moveHighlightedCells(from currentCoordinates: [Coordinate],
                              to newCoordinates: [Coordinate],
                              using color: Color? = nil) {
        
        guard currentCoordinates.count == newCoordinates.count else { return }
        
        /// Dehighlights the current cells and saves their colors to the new cells.
        zip(currentCoordinates, newCoordinates).forEach { (currentCoordinate, newCoordinate) in
            guard
                let currentCell = cell(at: currentCoordinate),
                let newCell = cell(at: newCoordinate) else { return }
            
            newCell.color = currentCell.color
            currentCell.isOpen = true
        }
        
        highlightCells(at: newCoordinates, using: color)
    }

    func highlightCells(at coordinates: [Coordinate], using color: Color? = nil) {
        
        coordinates.forEach { coordinate in
            guard let cell = self.cell(at: coordinate) else { return }
            cell.isOpen = false
            
            if let color = color {
                cell.color = color
            }
        }
    }
    
    func dehighlightCells(at coordinates: [Coordinate]) {
        
        coordinates.forEach { coordinate in
            guard let cell = self.cell(at: coordinate) else { return }
            cell.isOpen = true
        }
    }
    
    func cellsAreOpen(at coordinates: [Coordinate]) -> Bool {
        
        for coordinate in coordinates {
            guard
                let cell = self.cell(at: coordinate),
                cell.isOpen else {
                    
                    return false
            }
        }
        
        return true
    }
    
    func shadeCells(at coordinates: [Coordinate]) {
        
        cells.forEach { rowCells in
            rowCells.forEach { $0.isShaded = false }
        }
        
        coordinates.forEach { coordinate in
            guard let cell = self.cell(at: coordinate) else { return }
            cell.isShaded = true
        }
    }
}

private final class CellIterator: Equatable {
    
    let cell: Cell
    var isVisited = false
    
    init(cell: Cell) {
        
        self.cell = cell
    }
    
    static func == (lhs: CellIterator, rhs: CellIterator) -> Bool {
        
        return lhs.cell === rhs.cell &&
            lhs.isVisited == rhs.isVisited
    }
}
