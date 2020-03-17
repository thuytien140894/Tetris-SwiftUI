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
    @State private var tetrominoQueue: [Tetromino] = []
    @State private var savedTetromino: Tetromino?
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            HoldView(tetromino: $savedTetromino) { self.gameManager?.saveTetromino() }
                .frame(width: 80, height: 100)
            
            GeometryReader { geometry in
                BoardView(board: self.$board, cellWidth: self.$cellWidth)
                    .onAppear(perform: { self.setUpBoard(size: geometry.size) })
                    .onTapGesture { self.gameManager?.rotateTetromino() }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                value.translation.width > 0
                                    ? self.gameManager?.moveTetrominoRight()
                                    : self.gameManager?.moveTetrominoLeft()
                            }
                )
            }
            
            TetrominoQueueView(queue: $tetrominoQueue)
                .frame(width: 80, height: 240)
        }
        .padding(EdgeInsets(top: 150, leading: 5, bottom: 20, trailing: 5))
    }
    
    private func setUpBoard(size: CGSize) {
        
        board = makeBoard(width: size.width, height: size.height)
        cellWidth = size.width / CGFloat(board.columnCount)
        
        let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        tetrominoQueue = (0..<3).map { _ in generateTetromino() }
        gameManager = GameManager(board: $board,
                                  tetrominoQueue: $tetrominoQueue,
                                  savedTetromino: $savedTetromino,
                                  eventTrigger: timer.eraseToAnyPublisher(),
                                  tetrominoGenerator: generateTetromino)
        
        DispatchQueue.main.async {
            self.gameManager?.startGame()
        }
    }
    
    private func makeBoard(width: CGFloat, height: CGFloat) -> Board {
        
        let columnCount = 10
        let screenRatio = height / width
        let estimatedRowCount = CGFloat(columnCount) * screenRatio
        let rowCount = Int(estimatedRowCount.rounded(.down))
        let board = Board(rowCount: rowCount, columnCount: columnCount)
        
        return board
    }
    
    private func generateTetromino() -> Tetromino {
        
        let type = TetrominoType.allCases.randomElement() ?? .i
        let orientation = Orientation.allCases.randomElement() ?? .one
        
        let tetromino = Tetromino(type: type, orientation: orientation)
        let availableSpace = board.columnCount - tetromino.width
        let xOffset = Int.random(in: 0..<availableSpace)
        tetromino.adjustXPositionFromOrigin(by: xOffset)
        
        return tetromino
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
