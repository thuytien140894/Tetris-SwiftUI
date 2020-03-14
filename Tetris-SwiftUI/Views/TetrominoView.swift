//
//  TetrominoView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/14/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct TetrominoView: View {
    
    private let tetromino: Tetromino
    private var cells: [[Cell]] = [[]]
    
    init(type: TetrominoType) {
        
        tetromino = Tetromino(type: type, orientation: .one)
        cells = makeCells()
        
        /// Highlights the cells that correspond to the
        /// tetromino coordinates.
        tetromino.coordinates.forEach { coordinate in
            let row = coordinate.y
            let column = coordinate.x
            let cell = cells[row][column]
            cell.isOpen = false
            cell.color = tetromino.color
        }
        
        hideOpenCells()
    }
    
    private func makeCells() -> [[Cell]] {
        
        var newCells: [[Cell]] = []
        
        (0..<tetromino.height).forEach { row in
            let rowCells: [Cell] = (0..<tetromino.width).map { column in
                Cell(position: (column, row))
            }
            newCells.append(rowCells)
        }
        
        return newCells
    }
    
    private func hideOpenCells() {
        
        cells
            .flatMap { $0 }
            .filter { $0.isOpen }
            .forEach { $0.isHidden = true }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                ForEach(0..<self.tetromino.height, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<self.tetromino.width, id: \.self) { column in
                            CellView(cell: self.cells[row][column])
                                .frame(width: geometry.size.width / 5, height: geometry.size.width / 5)
                        }
                    }
                }
            }
        }
    }
}

struct TetrominoView_Previews: PreviewProvider {
    static var previews: some View {
        return TetrominoView(type: TetrominoType.t)
            .frame(width: 100, height: 100)
    }
}
