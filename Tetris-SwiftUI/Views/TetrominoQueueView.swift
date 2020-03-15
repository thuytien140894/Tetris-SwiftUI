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
        VStack(alignment: .center, spacing: 20) {
            Text("NEXT")
                .fontWeight(.bold)
            
            if queue.count > 0 {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.sRGBLinear, red: 0.2, green: 0.5, blue: 0.95, opacity: 0.3))
                    TetrominoView(type: queue[0].type)
                }
                ForEach(1..<queue.count) { index in
                    TetrominoView(type: self.queue[index].type)
                }
            }
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
