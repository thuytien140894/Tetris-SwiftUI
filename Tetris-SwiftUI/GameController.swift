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
        publishMovementResult(from: coordinates, to: [newCoordinates], fallback: .done)
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
                                       fallback: MovementResult = .notPossible) {
        
        let isOverlapped: (Coordinate) -> Bool = { coordinate in
            let matchedCoordinate = oldCoordinates.first(where: { $0 == coordinate })
            return matchedCoordinate != nil
        }
        
        let newCoordinates = newCoordinateOptions.first { coordinates in
            let filteredCoordinates = coordinates.filter { !isOverlapped($0) }
            return movementValidator(filteredCoordinates)
        }
        
        if let newCoordinates = newCoordinates {
            subject.send(.new(newCoordinates))
        } else {
            subject.send(fallback)
        }
    }
}
