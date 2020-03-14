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
}

/// According to our coordinate system, the y axis is inverted.
/// As a result, rotating by 90 degrees means rotating by 270
/// degrees and vice versa.
enum Orientation: Double, CaseIterable {
    case one = 0
    case two = 270
    case three = 180
    case four = 90
    
    /// Returns a new set of coordinates by rotating its original set
    /// by the current orientation and within an optional specified region.
    /// The input coordinates are first adjusted to the origin by
    /// the "middle" coordinate, then adjusted back to its original
    /// position after rotation.
    func rotate(coordinates: [Coordinate], within region: [Coordinate]? = nil) -> [Coordinate] {
        
        guard coordinates.count > 0 else {
            return []
        }
        
        let pivotPosition = Int(ceil(Double(coordinates.count) / 2))
        var adjustedCoordinates = Orientation.adjustCoordinatesToOrigin(coordinates,
                                                                        pivot: coordinates[pivotPosition - 1])
        
        /// Makes sure coordinates adjusted to the origin also lie within the
        /// specified region before rotation.
        if let region = region {
            adjustedCoordinates = adjust(coordinates: adjustedCoordinates, toFitWithin: region)
        }
        let xTheta = coordinates[0].x - adjustedCoordinates[0].x
        let yTheta = coordinates[0].y - adjustedCoordinates[0].y
        
        var rotatedCoordinates = rotate(coordinates: adjustedCoordinates)
        if let region = region {
            rotatedCoordinates = adjust(coordinates: rotatedCoordinates, toFitWithin: region)
        }
        
        rotatedCoordinates = rotatedCoordinates.map { coordinate in
            (coordinate.x + xTheta, coordinate.y + yTheta)
        }
        
        return rotatedCoordinates
    }
    
    /// Performs rotation on a set of coordinates by multiplying
    /// each coordinate by the rotation matrix.
    ///
    /// [cos(theta) -sin(theta)]
    /// [sin(theta) cos(theta) ]
    private func rotate(coordinates: [Coordinate]) -> [Coordinate] {
        
        let pi = rawValue * Double.pi / 180
        let cosTheta = cos(pi).rounded()
        let sinTheta = sin(pi).rounded()
        
        let rotatedCoordinates: [Coordinate] = coordinates.map { coordinate in
            let x = Double(coordinate.x)
            let y = Double(coordinate.y)
            let rotatedX = x * cosTheta - y * sinTheta
            let rotatedY = x * sinTheta + y * cosTheta
            
            return (Int(rotatedX), Int(rotatedY))
        }
        
        return rotatedCoordinates
    }
    
    /// Adjusts a set of coordinates to fit within the specified region.
    private func adjust(coordinates: [Coordinate], toFitWithin region: [Coordinate]) -> [Coordinate] {
        
        guard
            region.count == 2,
            let maxX = (coordinates.map { $0.x }).max(),
            let minX = (coordinates.map { $0.x }).min(),
            let maxY = (coordinates.map { $0.y }).max(),
            let minY = (coordinates.map { $0.y }).min() else {
                
                return coordinates
        }
        
        let minXThreshold = region[0].x
        let maxXThreshold = region[1].x
        let minYThreshold = region[1].y
        let maxYThreshold = region[0].y
        
        let xRange = minXThreshold...maxXThreshold
        var xOffset = 0
        if !xRange.contains(minX) {
            xOffset = minXThreshold - minX
        } else if !xRange.contains(maxX) {
            xOffset = maxXThreshold - maxX
        }
        
        let yRange = minYThreshold...maxYThreshold
        var yOffset = 0
        if !yRange.contains(minY) {
            yOffset = minYThreshold - minY
        } else if !yRange.contains(maxY) {
            yOffset = maxYThreshold - maxY
        }
        
        let adjustedCoordinates = coordinates.map { coordinate in
            (coordinate.x + xOffset, coordinate.y + yOffset)
        }
        
        return adjustedCoordinates
    }
    
    static func adjustCoordinatesToOrigin(_ coordinates: [Coordinate], pivot coordinate: Coordinate) -> [Coordinate] {
        
        let xTheta = 0 - coordinate.x
        let yTheta = 0 - coordinate.y
        
        let adjustedCoordinates = coordinates.map { coordinate in
            (coordinate.x + xTheta, coordinate.y + yTheta)
        }
        
        return adjustedCoordinates
    }
}

class Tetromino: ObservableObject, Identifiable {
    
    let id = UUID()
    let type: TetrominoType
    let orientation: Orientation
    let color: Color
    
    var coordinates: [Coordinate] = []
    
    convenience init() {
        
        self.init(type: .i, orientation: .one, color: .white)
    }
    
    init(type: TetrominoType, orientation: Orientation, color: Color) {
        
        self.type = type
        self.orientation = orientation
        self.color = color
        
        coordinates = initialCoordinates()
    }
    
    /// Calculates the tetromino's coordinates using its type and orientation.
    /// Then adjusts the coordinates so that their y values are non-negative.
    /// X values should already be non-negative, regardless of rotation.
    private func initialCoordinates() -> [Coordinate] {
        
        var currentCoordinates = orientation.rotate(coordinates: type.coordinates, within: type.enclosedRegion)
        
        var yOffset = 0
        if let minY = (currentCoordinates.map { $0.y }).min() {
            yOffset = -minY
        }
        
        currentCoordinates = currentCoordinates.map { ($0.x, $0.y + yOffset) }
        return currentCoordinates
    }
    
    var xPosition = 0 {
        didSet {
            coordinates = coordinates.map { coordinate in
                (coordinate.x + xPosition, coordinate.y)
            }
        }
    }
    
    var width: Int {
        guard
            let maxX = (coordinates.map { $0.x }).max(),
            let minX = (coordinates.map { $0.x }).min() else {
                return 0
        }
        
        return maxX - minX + 1
    }
    
    var height: Int {
        guard
            let maxY = (coordinates.map { $0.y }).max(),
            let minY = (coordinates.map { $0.y }).min() else {
                return 0
        }
        
        return maxY - minY + 1
    }
    
    /// Initial coordinates for each tetromino place it
    /// outside the board, specifically one row above the
    /// first row so that the tetromino can start descending
    /// into view. As a result, we adjust the y values to be
    /// less than 0.
    func prepareInitialCoordinatesOnBoard() {
        
        var adjustedYTheta = 0
        if let maxY = (coordinates.map { $0.y }).max() {
            adjustedYTheta = maxY + 1
        }
        
        let adjustedCoordinates = coordinates.map { coordinate in
            (coordinate.x, coordinate.y - adjustedYTheta)
        }
        
        coordinates = adjustedCoordinates
    }
    
    static func compare(coordinates: [Coordinate], anotherCoordinates: [Coordinate]) -> Bool {
        
        guard coordinates.count == anotherCoordinates.count else {
            return false
        }
        
        for (coordinate, anotherCoordinate) in zip(coordinates, anotherCoordinates)
            where coordinate != anotherCoordinate {
                return false
        }
        
        return true
    }
}
