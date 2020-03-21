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
    
    @State private var cellWidth: CGFloat = 0
    
    private let spacing: CGFloat = 2
    
    init(board: Binding<Board>) {
        
        self._board = board
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack(spacing: self.spacing) {
                ForEach(0..<self.board.rowCount, id: \.self) { row in
                    HStack(spacing: self.spacing) {
                        ForEach(0..<self.board.columnCount, id: \.self) { column in
                            CellView(cell: self.board.cells[row][column])
                                .frame(width: self.cellWidth, height: self.cellWidth)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 4)
            )
            .onAppear(perform: { self.setUpBoard(width: geometry.size.width, height: geometry.size.height) })
        }
    }
    
    private func setUpBoard(width: CGFloat, height: CGFloat) {
        
        let columnCount = 10
        let screenRatio = height / width
        let estimatedRowCount = CGFloat(columnCount) * screenRatio
        let rowCount = Int(estimatedRowCount.rounded(.down))
        board = Board(rowCount: rowCount, columnCount: columnCount)
        
        let totalSpacing = spacing * CGFloat(columnCount)
        cellWidth = (width - totalSpacing) / CGFloat(columnCount)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        let board = Board(rowCount: 4, columnCount: 5)
        board.cells[3][1].isShaded = true
        board.cells[3][2].isShaded = true
        return BoardView(board: .constant(board))
    }
}
