//
//  ScoreView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/21/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct ScoreView: View {
    
    @Binding private var score: Int
    
    init(score: Binding<Int>) {

        self._score = score
    }
    
    var body: some View {
        HStack {
            Image(systemName: "star.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color(red: 1, green: 215/255, blue: 0))
            Text("\(score)")
                .font(.system(size: 40, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.black.opacity(0.8))
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(score: .constant(100))
    }
}
