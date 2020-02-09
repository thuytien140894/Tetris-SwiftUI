//
//  Tetromino.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/30/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

typealias Coordinate = (x: Int, y: Int)

enum TetrominoType: CaseIterable {
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
    
    /// Coordinates are located around the origin (0, 0) for
    /// correct rotation.
    var coordinates: [Coordinate] {
        switch self {
        case .i:
            return [(-1, 0), (0, 0), (1, 0), (2, 0)]
        case .o:
            return [(0, 1), (0, 0), (1, 0), (1, 1)]
        case .t:
            return [(-1, 0), (0, 0), (1, 0), (0, 1)]
        case .j:
            return [(1, 0), (0, 0), (-1, 0), (-1, 1)]
        case .l:
            return [(-1, 0), (0, 0), (1, 0), (1, 1)]
        case .s:
            return [(-1, 0), (0, 0), (0, 1), (1, 1)]
        case .z:
            return [(1, 0), (0, 0), (0, 1), (-1, 1)]
        }
    }
}

enum Orientation: Double, CaseIterable {
    case one = 0
    case two = 90
    case three = 180
    case four = 270
    
    func width(fromDimension dimension: (width: Int, height: Int)) -> Int {
        
        switch self {
        case .one, .three:
            return dimension.1
        case .two, .four:
            return dimension.0
        }
    }
    
    func rotate(coordinates: [Coordinate]) -> [Coordinate] {
        
        let pi = rawValue * Double.pi / 180
        
        let rotatedCoordinates: [Coordinate] = coordinates.map { coordinate in
            let x = Double(coordinate.x)
            let y = Double(coordinate.y)
            let cosTheta = cos(pi).rounded()
            let sinTheta = sin(pi).rounded()
            let rotatedX = x * cosTheta - y * sinTheta
            let rotatedY = x * sinTheta + y * cosTheta
            
            return (Int(rotatedX), Int(rotatedY))
        }
        
        return rotatedCoordinates
    }
}

struct Tetromino {
    
    let type: TetrominoType
    let orientation: Orientation
    let color: Color
    
    var xPosition = 0 {
        didSet {
            coordinates = coordinates.map { coordinate in
                (coordinate.x + xPosition, coordinate.y)
            }
        }
    }
    
    var width: Int {
        let dimension = type.dimension
        return orientation.width(fromDimension: dimension)
    }
    
    lazy var coordinates: [Coordinate] = {
        makeCoordinates()
    }()
    
    /// When a tetromino first appears on the board, its cells
    /// should be above the first row so that it can descend into
    /// view later. As a result, we adjust the y values to be
    /// less than 0. Also, since tetromino coordinates are located
    /// around the origin, x values can be negative, which are
    /// invalid for board indexing. We want to adjust these x values
    /// to be greater than or equal to 0.
    private func makeCoordinates() -> [Coordinate] {
        
        let originalCoordinates = orientation.rotate(coordinates: type.coordinates)
        var adjustedXTheta = 0
        var adjustedYTheta = 0
        
        originalCoordinates.forEach { coordinate in
            if coordinate.x < adjustedXTheta {
                adjustedXTheta = coordinate.x
            }
            
            if coordinate.y < adjustedYTheta {
                adjustedYTheta = coordinate.y
            }
        }
        
        adjustedXTheta = abs(adjustedXTheta)
        adjustedYTheta = abs(adjustedYTheta) + 1
        
        /// We treat the board's row numbers as y values. Tetromino
        /// coordinates follow the traditional y-axis where positive
        /// y values are upward. Therefore, we invert the y coordinates
        /// to match the board's "coordinate" system.
        let adjustedCoordinates = originalCoordinates.map { coordinate in
            (coordinate.x + adjustedXTheta, -(coordinate.y + adjustedYTheta))
        }
        
        return adjustedCoordinates
    }
    
    mutating func contains(coordinate: Coordinate) -> Bool {
        
        let matchedCoordinate = coordinates.first(where: { $0 == coordinate })
        return matchedCoordinate != nil
    }
}

extension Tetromino {
    
    init() {
        
        self.init(type: .i, orientation: .one, color: Color.white)
    }
}
