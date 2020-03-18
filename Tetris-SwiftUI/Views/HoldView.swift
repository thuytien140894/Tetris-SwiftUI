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
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.blue.opacity(0.5))
            
            VStack(alignment: .center, spacing: 0) {
                Text("HOLD")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black.opacity(0.8))
                    .padding()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.black.opacity(0.8))
                    
                    if tetromino != nil {
                        TetrominoView(type: tetromino!.type)
                            .padding(5)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
                .onTapGesture { self.actionHandler() }
            }
        }
    }
}

struct HoldView_Previews: PreviewProvider {
    static var previews: some View {
        HoldView(tetromino: .constant(Tetromino())) { return }
            .frame(width: 80, height: 120)
    }
}
