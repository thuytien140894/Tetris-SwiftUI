//
//  CellView.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/29/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

struct CellView: View {
    
    @ObservedObject var cell: Cell
    
    var body: some View {
        Rectangle()
            .fill(cell.isOpen ? Color.black : cell.color)
            .opacity(0.8)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(cell: Cell())
            .frame(width: 50, height: 50)
    }
}
