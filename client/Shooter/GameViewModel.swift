//
//  GameViewModel.swift
//  Shooter
//
//  Created by Roman Matveev on 21.07.2022.
//

import Foundation

struct GameViewModel {
    
    var connectButton: Button
    
    var disconnectButton: Button
}

extension GameViewModel {
    
    struct Button {
        
        var title: String
        
        var isEnabled: Bool
    }
}
