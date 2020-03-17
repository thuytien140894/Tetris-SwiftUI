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
        let view = RoundedRectangle(cornerRadius: 2)
            .fill(cell.isOpen ? Color.black : cell.color)
            .opacity(cell.isShaded ? 0 : 0.8)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.blue, lineWidth: cell.isShaded ? 2 : 0)
            )
        return
            cell.isHidden
                ? AnyView(view.hidden())
                : AnyView(view)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(cell: Cell())
            .frame(width: 50, height: 50)
    }
}
