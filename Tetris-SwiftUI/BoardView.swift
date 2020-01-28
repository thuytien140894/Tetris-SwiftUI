//
//  BoardView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/27/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct BoardView: View {
    
    private let numberOfRows: Int
    private let numberOfColumns = 10
    private let cellWidth: CGFloat
    
    init(width: CGFloat, height: CGFloat) {
        
        let screenRatio = height / width
        let estimatedNumberOfRows = CGFloat(numberOfColumns) * screenRatio
        numberOfRows = Int(estimatedNumberOfRows.rounded(.down))
        
        cellWidth = width / CGFloat(numberOfColumns)
    }
    
    var body: some View {
        
        VStack(spacing: 2) {
            ForEach(0 ..< numberOfRows, id: \.self) { _ in
                HStack(spacing: 2) {
                    ForEach(0 ..< self.numberOfColumns, id: \.self) { _ in
                        Rectangle()
                            .frame(width: self.cellWidth, height: self.cellWidth)
                        .opacity(0.8)
                    }
                }
            }
        }

    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(width: 414, height: 750)
    }
}
