//
//  GameController.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 2/11/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import Combine

enum MovementResult {
    case new(_ oldValue: [Coordinate], _ newValue: [Coordinate])
    case locked
}

extension MovementResult: Equatable {
    
    static func == (lhs: MovementResult, rhs: MovementResult) -> Bool {
        
        switch lhs {
        case .new(let oldValue, let newValue):
            switch rhs {
            case .new(let anotherOldValue, let anotherNewValue):
                return
                    Tetromino.compare(coordinates: oldValue, anotherCoordinates: anotherOldValue) &&
                    Tetromino.compare(coordinates: newValue, anotherCoordinates: anotherNewValue)
            default:
                return false
            }
        case .locked:
            switch rhs {
            case .locked:
                return true
            default:
                return false
            }
        }
    }
}

struct GameController {
    
    private let subject: PassthroughSubject<MovementResult, Never>
    private let movementValidator: ([Coordinate]) -> Bool
    
    init(subject: PassthroughSubject<MovementResult, Never>, movementValidator: @escaping ([Coordinate]) -> Bool) {
        
        self.subject = subject
        self.movementValidator = movementValidator
    }
    
    func drop(coordinates: [Coordinate]) {
    
        let newCoordinates = coordinates.map { ($0.x, $0.y + 1) }
        publishMovementResult(from: coordinates, to: [newCoordinates], shouldNotifyFailure: true)
    }
    
    /// Drops the coordinates until they can
    /// no longer be dropped.
    func hardDrop(coordinates: [Coordinate]) {
        
        var currentCoordinates: [Coordinate] = []
        var newCoordinates = coordinates
        var filteredCoordinates: [Coordinate] = []
        repeat {
            currentCoordinates = newCoordinates
            newCoordinates = currentCoordinates.map { ($0.x, $0.y + 1) }
            filteredCoordinates = exclude(coordinates: newCoordinates, from: currentCoordinates)
        } while movementValidator(filteredCoordinates)
        
        subject.send(.new(coordinates, currentCoordinates))
    }
    
    func moveRight(coordinates: [Coordinate]) {
        
        let newCoordinates = coordinates.map { ($0.x + 1, $0.y) }
        publishMovementResult(from: coordinates, to: [newCoordinates])
    }
    
    func moveLeft(coordinates: [Coordinate]) {
        
        let newCoordinates = coordinates.map { ($0.x - 1, $0.y) }
        publishMovementResult(from: coordinates, to: [newCoordinates])
    }
    
    func rotate(coordinates: [Coordinate], within region: [Coordinate]? = nil) {
        
        let firstOption = coordinates
        let secondOption = coordinates.map { ($0.x - 1, $0.y) }
        let thirdOption = coordinates.map { ($0.x - 2, $0.y) }
        let fourthOption = coordinates.map { ($0.x + 1, $0.y) }
        
        let coordinatesOptions = [firstOption, secondOption, thirdOption, fourthOption].map {
            Orientation.four.rotate(coordinates: $0, within: region)
        }
        publishMovementResult(from: coordinates, to: coordinatesOptions)
    }
    
    private func publishMovementResult(from oldCoordinates: [Coordinate],
                                       to newCoordinateOptions: [[Coordinate]],
                                       shouldNotifyFailure: Bool = false) {
        
        let newCoordinates = newCoordinateOptions.first { coordinates in
            let filteredCoordinates = exclude(coordinates: coordinates, from: oldCoordinates)
            return movementValidator(filteredCoordinates)
        }
    
        if let newCoordinates = newCoordinates {
            subject.send(.new(oldCoordinates, newCoordinates))
        } else if shouldNotifyFailure {
            subject.send(.locked)
        }
    }
    
    private func exclude(coordinates: [Coordinate],
                         from anotherCoordinates: [Coordinate]) -> [Coordinate] {
        
        let isOverlapped: (Coordinate) -> Bool = { coordinate in
            let matchedCoordinate = anotherCoordinates.first(where: { $0 == coordinate })
            return matchedCoordinate != nil
        }
        
        let filteredCoordinates = coordinates.filter { !isOverlapped($0) }
        return filteredCoordinates
    }
}
