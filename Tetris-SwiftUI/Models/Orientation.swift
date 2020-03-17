//
//  Orientation.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/16/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import Foundation

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
        
        var adjustedCoordinates = adjustCoordinatesToOrigin(coordinates)
        
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
    
    private func adjustCoordinatesToOrigin(_ coordinates: [Coordinate]) -> [Coordinate] {
        
        let pivotPosition = Int(ceil(Double(coordinates.count) / 2))
        let pivotCoordinate = coordinates[pivotPosition - 1]
        
        let xTheta = -pivotCoordinate.x
        let yTheta = -pivotCoordinate.y
        
        let adjustedCoordinates = coordinates.map { coordinate in
            (coordinate.x + xTheta, coordinate.y + yTheta)
        }
        
        return adjustedCoordinates
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
}
