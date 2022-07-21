//
//  Extensions.swift
//  Shooter
//
//  Created by Roman Matveev on 21.07.2022.
//

import Foundation

extension DispatchQueue {
    
    static func main(_ closure: () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync { closure() }
        }
    }
}
