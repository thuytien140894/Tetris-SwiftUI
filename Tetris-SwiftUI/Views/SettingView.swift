//
//  SettingView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/23/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

protocol SettingActionHandler: class {
    func startGame()
    func pauseGame()
    func continueGame()
}

struct SettingView: View {
    
    private let actionHandler: SettingActionHandler?
    @Binding private var isPresented: Bool
    
    init(actionHandler: SettingActionHandler?,
         isPresented: Binding<Bool>) {
        
        self.actionHandler = actionHandler
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.85)
                .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 25) {
                Button(action: {
                    self.isPresented = false
                    self.actionHandler?.startGame()
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                        Text("NEW GAME")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(3)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 0.5)
                )
                
                Button(action: {
                    self.isPresented = false
                    self.actionHandler?.continueGame()
                }) {
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                        Text("CONTINUE")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(10)
                .padding(3)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 0.5)
                )
            }
            .padding()
        }
        .onAppear(perform: { self.actionHandler?.pauseGame() })
    }
}

struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(actionHandler: nil, isPresented: .constant(true))
    }
}
