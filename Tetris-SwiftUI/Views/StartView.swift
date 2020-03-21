//
//  StartView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/21/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct StartView: View {
    
    private let actionHandler: () -> Void
    
    init(actionHandler: @escaping () -> Void) {
        
        self.actionHandler = actionHandler
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                HStack(spacing: 0) {
                    Text("T")
                        .foregroundColor(.green)
                    Text("E")
                        .foregroundColor(.yellow)
                    Text("T")
                        .foregroundColor(.red)
                    Text("R")
                        .foregroundColor(.blue)
                    Text("I")
                        .foregroundColor(.purple)
                    Text("S")
                        .foregroundColor(.orange)
                }
                .font(.system(size: 90, weight: .bold, design: .rounded))
                
                Button(action: actionHandler) {
                    Text("PLAY")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.black.opacity(0.8))
                        .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
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

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView { return }
    }
}
