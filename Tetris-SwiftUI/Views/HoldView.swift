//
//  HoldView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/14/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct HoldView: View {
    
    @Binding private var tetromino: Tetromino?
    private let actionHandler: () -> Void
    
    init(tetromino: Binding<Tetromino?>, actionHandler: @escaping () -> Void) {
        
        self._tetromino = tetromino
        self.actionHandler = actionHandler
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("HOLD")
                .fontWeight(.bold)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.sRGBLinear, red: 0.2, green: 0.95, blue: 0.5, opacity: 0.3))
                if tetromino != nil {
                    TetrominoView(type: tetromino!.type)
                }
            }
            .onTapGesture { self.actionHandler() }
        }
    }
}

struct HoldView_Previews: PreviewProvider {
    static var previews: some View {
        HoldView(tetromino: .constant(Tetromino())) { return }
            .frame(width: 80, height: 120)
    }
}
