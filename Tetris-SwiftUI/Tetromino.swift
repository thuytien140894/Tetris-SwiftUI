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
    
    /// Coordinates are used to index the board and modify
    /// its cells' states, and so our coordinate system inverts
    /// the y axis. Initial coordinates for each tetromino
    /// place it outside the board, specifically one row above the
    /// first row so that the tetromino can start descending into
    /// view.
    var coordinates: [Coordinate] {
        switch self {
        case .i:
            return [(0, -1), (1, -1), (2, -1), (3, -1)]
        case .o:
            return [(0, -2), (0, -1), (1, -1), (1, -2)]
        case .t:
            return [(0, -1), (1, -1), (2, -1), (1, -2)]
        case .j:
            return [(2, -1), (1, -1), (0, -1), (0, -2)]
        case .l:
            return [(0, -1), (1, -1), (2, -1), (2, -2)]
        case .s:
            return [(0, -1), (1, -1), (1, -2), (2, -2)]
        case .z:
            return [(2, -1), (1, -1), (1, -2), (0, -2)]
        }
    }
}

/// According to our coordinate system, the y axis is inverted.
/// As a result, rotating by 90 degrees means rotating by 270
/// degrees and vice versa.
enum Orientation: Double, CaseIterable {
    case one = 0
    case two = 270
    case three = 180
    case four = 90
    
    func width(fromDimension dimension: (width: Int, height: Int)) -> Int {
        
        switch self {
        case .one, .three:
            return dimension.0
        case .two, .four:
            return dimension.1
        }
    }
    
    /// Returns a new set of coordinates by rotating its original set
    /// according to the current orientation. The input coordinates
    /// are first adjusted to the origin by the "middle" coordinate,
    /// and then adjusted back to its original position after rotation.
    func rotate(coordinates: [Coordinate]) -> [Coordinate] {
        
        guard coordinates.count > 0 else { return [] }
        
        let pivotPosition = Int(ceil(Double(coordinates.count) / 2))
        let adjustedCoordinates = adjustCoordinatesToOrigin(coordinates, pivot: coordinates[pivotPosition - 1])
        let xTheta = coordinates[0].x - adjustedCoordinates[0].x
        let yTheta = coordinates[0].y - adjustedCoordinates[0].y
        
        let pi = rawValue * Double.pi / 180
        
        let rotatedCoordinates: [Coordinate] = adjustedCoordinates.map { coordinate in
            let x = Double(coordinate.x)
            let y = Double(coordinate.y)
            let cosTheta = cos(pi).rounded()
            let sinTheta = sin(pi).rounded()
            let rotatedX = x * cosTheta - y * sinTheta
            let rotatedY = x * sinTheta + y * cosTheta
            
            return (Int(rotatedX) + xTheta, Int(rotatedY) + yTheta)
        }
        
        return rotatedCoordinates
    }
    
    private func adjustCoordinatesToOrigin(_ coordinates: [Coordinate], pivot coordinate: Coordinate) -> [Coordinate] {
        
        let xTheta = 0 - coordinate.x
        let yTheta = 0 - coordinate.y
        
        let adjustedCoordinates = coordinates.map { coordinate in
            (coordinate.x + xTheta, coordinate.y + yTheta)
        }
        
        return adjustedCoordinates
    }
    
    func next() -> Self {
        
        let allOrientations = Orientation.allCases
        let currentOrientation = allOrientations.firstIndex(of: self)
        let nextOrientation = allOrientations.index(after: currentOrientation ?? 0)
        
        return allOrientations[nextOrientation % allOrientations.count]
    }
}

class Tetromino: ObservableObject {
    
    let type: TetrominoType
    let orientation: Orientation
    let color: Color
    
    @Published var coordinates: [Coordinate] = []
    
    convenience init() {
        
        self.init(type: .i, orientation: .one, color: .white)
    }
    
    init(type: TetrominoType, orientation: Orientation, color: Color) {
        
        self.type = type
        self.orientation = orientation
        self.color = color
        
        coordinates = makeInitialCoordinates()
    }
    
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
    
    /// When a tetromino first appears on the board, its cells
    /// should be above the first row so that it can descend into
    /// view later. As a result, we adjust the y values to be
    /// less than 0. x values can also be negative after rotation
    /// and so are adjusted to be greater than or equal to 0.
    private func makeInitialCoordinates() -> [Coordinate] {
        
        let originalCoordinates = orientation.rotate(coordinates: type.coordinates)
        var adjustedXTheta = 0
        var adjustedYTheta = 0
        
        originalCoordinates.forEach { coordinate in
            if coordinate.x < adjustedXTheta {
                adjustedXTheta = coordinate.x
            }
            
            if coordinate.y > adjustedYTheta {
                adjustedYTheta = coordinate.y
            }
        }
        
        adjustedXTheta = abs(adjustedXTheta)
        adjustedYTheta = adjustedYTheta + 1
        
        let adjustedCoordinates = originalCoordinates.map { coordinate in
            (coordinate.x + adjustedXTheta, coordinate.y - adjustedYTheta)
        }
        
        return adjustedCoordinates
    }
    
    static func compare(coordinates: [Coordinate], anotherCoordinates: [Coordinate]) -> Bool {
        
        guard coordinates.count == anotherCoordinates.count else {
            return false
        }
        
        for (coordinate, anotherCoordinate) in zip(coordinates, anotherCoordinates) {
            if coordinate != anotherCoordinate {
                return false
            }
        }
        
        return true
    }
}
