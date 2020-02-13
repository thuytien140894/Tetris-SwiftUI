//
//  GameController.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 2/11/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import Combine

enum MovementResult {
    case new([Coordinate])
    case notPossible
    case done
}

extension MovementResult: Equatable {
    
    static func == (lhs: MovementResult, rhs: MovementResult) -> Bool {
        
        switch lhs {
        case .new(let coordinates):
            switch rhs {
            case .new(let anotherCoordinates):
                return Tetromino.compare(coordinates: coordinates, anotherCoordinates: anotherCoordinates)
            default:
                return false
            }
        case .notPossible:
            switch rhs {
            case .notPossible:
                return true
            default:
                return false
            }
        case .done:
            switch rhs {
            case .done:
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
    
        publishMovementResult(from: coordinates, to: newCoordinates, fallback: .done)
    }
    
    func moveRight(coordinates: [Coordinate]) {
        
        let newCoordinates = coordinates.map { ($0.x + 1, $0.y) }
        
        publishMovementResult(from: coordinates, to: newCoordinates)
    }
    
    func moveLeft(coordinates: [Coordinate]) {
        
        let newCoordinates = coordinates.map { ($0.x - 1, $0.y) }
        
        publishMovementResult(from: coordinates, to: newCoordinates)
    }
    
    func rotate(coordinates: [Coordinate], to orientation: Orientation) {
        
        let newCoordinates = orientation.rotate(coordinates: coordinates)
        
        publishMovementResult(from: coordinates, to: newCoordinates)
    }
    
    private func publishMovementResult(from oldCoordinates: [Coordinate], to newCoordinates: [Coordinate], fallback: MovementResult = .notPossible) {
        
        let isOverlapped: (Coordinate) -> Bool = { coordinate in
            let matchedCoordinate = oldCoordinates.first(where: { $0 == coordinate })
            return matchedCoordinate != nil
        }
        let filteredCoordinates = newCoordinates.filter { !isOverlapped($0) }
        
        if movementValidator(filteredCoordinates) {
            subject.send(.new(newCoordinates))
        } else {
            subject.send(fallback)
        }
    }
}
