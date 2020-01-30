//
//  BoardView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/27/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct BoardView: View {
    
    private let cellWidth: CGFloat
    private let board: Board
    
    init(width: CGFloat, height: CGFloat) {
        
        let columnCount = 10
        let screenRatio = height / width
        let estimatedRowCount = CGFloat(columnCount) * screenRatio
        let rowCount = Int(estimatedRowCount.rounded(.down))
        board = Board(rowCount: rowCount, columnCount: columnCount)
        
        cellWidth = width / CGFloat(columnCount)
    }
    
    var body: some View {
        
        VStack {
            Button("Test") {
                let cell = self.board.cells[0][0]
                cell.isOpen = false
                cell.color = Color.blue
            }
            VStack(spacing: 2) {
                ForEach(0..<self.board.rowCount, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<self.board.columnCount, id: \.self) { column in
                            CellView(cell: self.board.cells[row][column])
                                .frame(width: self.cellWidth, height: self.cellWidth)
                        }
                    }
                }
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(width: 300, height: 700)
    }
}
