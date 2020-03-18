//
//  TetrominoQueueView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/14/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct TetrominoQueueView: View {
    
    @Binding var queue: [Tetromino]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.blue.opacity(0.5))
            
            VStack(alignment: .center, spacing: 20) {
                Text("NEXT")
                    .fontWeight(.bold)
                
                ForEach(queue) { tetromino in
                    TetrominoView(type: tetromino.type)
                }
            }
            .padding()
        }
    }
}

struct TetrominoQueueView_Previews: PreviewProvider {
    static var previews: some View {
        let tetrominos = [
            Tetromino(type: .o, orientation: .one),
            Tetromino(type: .s, orientation: .one),
            Tetromino(type: .z, orientation: .one)
        ]
        return TetrominoQueueView(queue: .constant(tetrominos))
            .frame(width: 80, height: 240)
    }
}
