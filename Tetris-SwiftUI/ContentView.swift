//
//  ContentView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/26/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        GeometryReader { geometry in
            BoardView(width: geometry.size.width, height: geometry.size.height)
        }
        .padding(EdgeInsets(top: 100, leading: 70, bottom: 20, trailing: 70))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
