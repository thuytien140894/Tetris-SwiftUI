//
//  Tetromino.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/30/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI
import Combine

class Tetromino: Identifiable {
    
    let id = UUID()
    let type: TetrominoType
    let orientation: Orientation
    let color: Color
    
    var positionIsChanged: PassthroughSubject<Void, Never>?
    
    var coordinates: [Coordinate] = [] {
        didSet {
            let oldXValues = oldValue.map { $0.x }
            let newXValues = coordinates.map { $0.x }
            
            /// Same x values mean the tetromino has
            /// only moved vertically. This is not
            /// considered a position change. 
            if !oldXValues.elementsEqual(newXValues) {
                positionIsChanged?.send()
            }
        }
    }
    
    convenience init() {
        
        self.init(type: .i, orientation: .one)
    }
    
    init(type: TetrominoType, orientation: Orientation) {
        
        self.type = type
        self.orientation = orientation
        self.color = type.color
        
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
    
    func adjustXPositionFromOrigin(by offset: Int) {
        
        guard let minX = (coordinates.map { $0.x }).min() else { return }
        coordinates = coordinates.map { coordinate in
            (coordinate.x - minX + offset, coordinate.y)
        }
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
