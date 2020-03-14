//
//  NextView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/14/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct NextView: View {
    
    @Binding var queue: [Tetromino]
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("NEXT")
                .fontWeight(.bold)
            ForEach(queue) { tetromino in
                TetrominoView(tetromino: tetromino)
            }
        }
        .frame(width: 80, height: 240)
    }
}

struct NextView_Previews: PreviewProvider {
    static var previews: some View {
        let tetrominos = [
            Tetromino(type: .o, orientation: .one, color: .blue),
            Tetromino(type: .s, orientation: .one, color: .red),
            Tetromino(type: .z, orientation: .one, color: .purple)
        ]
        return NextView(queue: .constant(tetrominos))
    }
}
