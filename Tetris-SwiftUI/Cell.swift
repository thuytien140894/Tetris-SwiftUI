//
//  Cell.swift
//  Tetris-SwiftUI
//
//  Created by Tien Thuy Ho on 1/27/20.
//  Copyright © 2020 Tien Thuy Ho. All rights reserved.
//

import SwiftUI

class Cell: ObservableObject {
    
    let position: Coordinate
    @Published var isOpen = true
    @Published var color: Color = .clear
    @Published var isHidden = false
    
    convenience init() {
        
        self.init(position: (0, 0))
    }
    
    init(position: Coordinate) {
        
        self.position = position
    }
}
