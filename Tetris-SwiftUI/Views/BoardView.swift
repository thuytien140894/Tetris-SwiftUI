//
//  BoardView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/27/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct BoardView: View {
    
    @Binding private var board: Board
    @Binding private var cellWidth: CGFloat
    
    init(board: Binding<Board>, cellWidth: Binding<CGFloat>) {
        
        self._board = board
        self._cellWidth = cellWidth
    }
    
    var body: some View {
        
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

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        let board = Board(rowCount: 4, columnCount: 5)
        board.cells[3][1].isShaded = true
        board.cells[3][2].isShaded = true
        return BoardView(board: .constant(board), cellWidth: .constant(50))
    }
}
