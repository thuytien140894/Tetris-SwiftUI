//
//  Tetrimino.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/30/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

enum TetriminoType {
    case i, o, t, j, l, s, z
    
    var dimension: (width: Int, height: Int) {
        switch self {
        case .i:
            return (4, 1)
        case .o:
            return (2, 2)
        default:
            return (3, 2)
        }
    }
}

enum Orientation {
    case one, two, three, four
    
    func width(fromDimension dimension: (width: Int, height: Int)) -> Int {
        
        switch self {
        case .one, .three:
            return dimension.0
        case .two, .four:
            return dimension.1
        }
    }
}

struct Tetrimino {
    
    let type: TetriminoType
    let orientation: Orientation
    let position: Int
    let color: Color
    
    var width: Int {
        let dimension = type.dimension
        return orientation.width(fromDimension: dimension)
    }
}
