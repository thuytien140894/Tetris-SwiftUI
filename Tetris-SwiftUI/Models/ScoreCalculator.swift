//
//  ScoreCalculator.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 3/21/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

final class ScoreCalculator: ObservableObject {
    
    @Published var score = 0
    
    func linesAreCleared(count: Int, usingHardDrop: Bool) {
        
        if usingHardDrop {
            score += count + 1
        }
        
        switch count {
        case 1:
            score += 40
        case 2:
            score += 100
        case 3:
            score += 300
        case 4:
            score += 1200
        default:
            return
        }
    }
    
    func reset() {
        
        score = 0
    }
}
