//
//  GameView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/26/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI
import Combine

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
    @State private var showStartView = true
    @State private var showSettingView = false
    @State private var showGameOver = false 
    
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
                    
                    VStack {
                        TetrominoQueueView(queue: $tetrominoQueue)
                            .frame(width: 80, height: 240)
                        
                        Spacer()
                        
                        Button(action: {
                            self.showSettingView = true
                        }) {
                            Image("settings")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color.black.opacity(0.8))
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 40, leading: 5, bottom: 0, trailing: 5))
            
            if showStartView {
                StartView(actionHandler: startGame)
            }
            
            if showSettingView {
                if self.gameManager != nil {
                    SettingView(actionHandler: self.gameManager!,
                                isPresented: $showSettingView)
                }
            }
            
            if showGameOver {
                GameOverView(score: scoreCalculator.score) {
                    self.showGameOver = false 
                    self.gameManager?.startGame()
                }
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
        
        self.gameManager?.startGame()
        
        showStartView = false
    }
    
    private func setUpGameManager() {
        
        let eventTrigger: () -> AnyPublisher<Date, Never> = {
            let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
            return timer.eraseToAnyPublisher()
        }
        
        tetrominoQueue = (0..<3).map { _ in generateTetromino() }
        gameManager = GameManager(board: $board,
                                  tetrominoQueue: $tetrominoQueue,
                                  savedTetromino: $savedTetromino,
                                  gameIsOver: $showGameOver,
                                  eventTrigger: eventTrigger,
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
