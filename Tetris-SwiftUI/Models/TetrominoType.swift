//
//  TetrominoType.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/16/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

typealias Coordinate = (x: Int, y: Int)

enum TetrominoType: CaseIterable {
    case i, o, t, j, l, s, z
    
    /// Coordinates are used to index the board and modify
    /// its cells' states, and so our coordinate system inverts
    /// the y axis.
    var coordinates: [Coordinate] {
        switch self {
        case .i:
            return [(0, 0), (1, 0), (2, 0), (3, 0)]
        case .o:
            return [(0, 0), (0, 1), (1, 1), (1, 0)]
        case .t:
            return [(0, 1), (1, 1), (2, 1), (1, 0)]
        case .j:
            return [(2, 1), (1, 1), (0, 1), (0, 0)]
        case .l:
            return [(0, 1), (1, 1), (2, 1), (2, 0)]
        case .s:
            return [(0, 1), (1, 1), (1, 0), (2, 0)]
        case .z:
            return [(2, 1), (1, 1), (1, 0), (0, 0)]
        }
    }
    
    /// The specified region within which a tetromino is
    /// enclosed regardless of its orientation. This
    /// region is defined by the coordinates of the
    /// two opposite corners along the ascending
    /// diagonal axis of the region.
    var enclosedRegion: [Coordinate] {
        switch self {
        case .i:
            return [(-1, 1), (2, -2)]
        case .o:
            return [(0, 0), (1, -1)]
        default:
            return [(-1, 1), (1, -1)]
        }
    }
    
    var color: Color {
        switch self {
        case .i:
            return .blue
        case .o:
            return .red
        case .t:
            return .yellow
        case .j:
            return .green
        case .l:
            return .purple
        case .s:
            return .orange
        case .z:
            return .pink
        }
    }
}
