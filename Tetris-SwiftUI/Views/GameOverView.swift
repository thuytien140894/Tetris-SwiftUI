//
//  GameOverView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/24/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct GameOverView: View {
    
    private let score: Int
    private let actionHandler: () -> Void
    
    init(score: Int, actionHandler: @escaping () -> Void) {
        
        self.score = score
        self.actionHandler = actionHandler
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.85)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 0) {
                    Text("G")
                        .foregroundColor(.green)
                    Text("A")
                        .foregroundColor(.yellow)
                    Text("M")
                        .foregroundColor(.red)
                    Text("E")
                        .foregroundColor(.blue)
                    Text(" ")
                    Text("O")
                        .foregroundColor(.purple)
                    Text("V")
                        .foregroundColor(.orange)
                    Text("E")
                        .foregroundColor(.blue)
                    Text("R")
                        .foregroundColor(.pink)
                }
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .padding()
                
                Text("SCORE: \(score)")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white.opacity(0.8))
                
                Spacer()
                    .frame(height: 100)
                
                Button(action: actionHandler) {
                    Text("TRY AGAIN")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.black.opacity(0.8))
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(3)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 0.5)
                    )
                }
            }
        }
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView(score: 100, actionHandler: {})
    }
}
