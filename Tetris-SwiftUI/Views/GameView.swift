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
    @State private var tetrominoQueue: [Tetromino] = []
    @State private var savedTetromino: Tetromino?
    @State private var showStartOverlay = true
    
    private let backgroundGradient = Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red])
    
    var body: some View {
        ZStack {
            AngularGradient(gradient: backgroundGradient,
                            center: .center)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            HStack(alignment: .top, spacing: 15) {
                HoldView(tetromino: $savedTetromino) { self.gameManager?.saveTetromino() }
                    .frame(width: 80, height: 120)
                
                BoardView(board: self.$board)
                    .onTapGesture { self.gameManager?.rotateTetromino() }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                value.translation.width > 0
                                    ? self.gameManager?.moveTetrominoRight()
                                    : self.gameManager?.moveTetrominoLeft()
                        }
                )
                
                TetrominoQueueView(queue: $tetrominoQueue)
                    .frame(width: 80, height: 240)
            }
            .padding(EdgeInsets(top: 100, leading: 5, bottom: 50, trailing: 5))
            
            if showStartOverlay {
                StartView(actionHandler: startGame)
            }
        }
        .onAppear(perform: setUpGameManager)
    }
    
    private func startGame() {
        
        DispatchQueue.main.async {
            self.gameManager?.startGame()
        }
        
        showStartOverlay = false
    }
    
    private func setUpGameManager() {
        
        let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        tetrominoQueue = (0..<3).map { _ in generateTetromino() }
        gameManager = GameManager(board: $board,
                                  tetrominoQueue: $tetrominoQueue,
                                  savedTetromino: $savedTetromino,
                                  eventTrigger: timer.eraseToAnyPublisher(),
                                  tetrominoGenerator: generateTetromino)
    }
    
    private func generateTetromino() -> Tetromino {
        
        let type = TetrominoType.allCases.randomElement() ?? .i
        let orientation = Orientation.allCases.randomElement() ?? .one
        return Tetromino(type: type, orientation: orientation)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
