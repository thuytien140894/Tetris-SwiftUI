//
//  GameView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/26/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct GameView: View {
    
    @State private var gameManager: GameManager?
    @State private var board = Board()
    @State private var cellWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            BoardView(board: self.$board, cellWidth: self.$cellWidth)
                .onAppear(perform: { self.setUpBoard(size: geometry.size) })
        }
        .padding(EdgeInsets(top: 100, leading: 70, bottom: 20, trailing: 70))
    }
    
    private func setUpBoard(size: CGSize) {
        
        board = makeBoard(width: size.width, height: size.height)
        cellWidth = size.width / CGFloat(board.columnCount)
        
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        gameManager = GameManager(board: $board, eventTrigger: timer.eraseToAnyPublisher())
        gameManager?.startGame()
    }
    
    private func makeBoard(width: CGFloat, height: CGFloat) -> Board {
        
        let columnCount = 10
        let screenRatio = height / width
        let estimatedRowCount = CGFloat(columnCount) * screenRatio
        let rowCount = Int(estimatedRowCount.rounded(.down))
        let board = Board(rowCount: rowCount, columnCount: columnCount)
        
        return board
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
