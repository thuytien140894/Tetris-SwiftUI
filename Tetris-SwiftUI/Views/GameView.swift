//
//  GameView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/26/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

extension HorizontalAlignment {
    enum ScoreAndBoardAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.trailing]
        }
    }

    static let scoreAndBoardAlignment = HorizontalAlignment(ScoreAndBoardAlignment.self)
}

struct GameView: View {
    
    @State private var gameManager: GameManager?
    @State private var board = Board()
    @State private var tetrominoQueue: [Tetromino] = []
    @State private var savedTetromino: Tetromino?
    @State private var showStartOverlay = true
    
    @ObservedObject private var scoreCalculator = ScoreCalculator()
    
    private let backgroundGradient = Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red])
    
    var body: some View {
        ZStack {
            AngularGradient(gradient: backgroundGradient,
                            center: .center)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .scoreAndBoardAlignment, spacing: 5) {
                ScoreView(score: self.$scoreCalculator.score)
                
                HStack(alignment: .top, spacing: 10) {
                    HoldView(tetromino: $savedTetromino) { self.gameManager?.saveTetromino() }
                        .frame(width: 80, height: 120)
                    
                    BoardView(board: self.$board)
                        .alignmentGuide(.scoreAndBoardAlignment) { d in d[.trailing] }
                    
                    TetrominoQueueView(queue: $tetrominoQueue)
                        .frame(width: 80, height: 240)
                }
            }
            .padding(EdgeInsets(top: 40, leading: 5, bottom: 40, trailing: 5))
            
            if showStartOverlay {
                StartView(actionHandler: startGame)
            }
        }
        .onAppear(perform: setUpGameManager)
        .onTapGesture { self.gameManager?.rotateTetromino() }
        .gesture(
            DragGesture().onEnded { self.dragGestureDidEnd(at: $0.translation) }
        )
    }
    
    private func dragGestureDidEnd(at offset: CGSize) {
        
        if offset.width > 0 { /// Swipe right.
            self.gameManager?.moveTetrominoRight()
        } else if offset.width < 0 { /// Swipe left.
            self.gameManager?.moveTetrominoLeft()
        } else if offset.height > 0 { /// Swipe down.
            self.gameManager?.hardDropTetromino()
        }
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
                                  scoreCalculator: scoreCalculator,
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
