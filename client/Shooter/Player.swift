//
//  Player.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import UIKit

enum Player {
    
    static var username: String {
        UserDefaults.standard.string(forKey: "username")!
    }
}
