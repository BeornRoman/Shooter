//
//  SocketServiceDelegate.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import Foundation

protocol SocketServiceDelegate: AnyObject {
    
    func recieved(message: String)

    func setup()
    
    func waiting(error: Error)
    
    func preparing()
    
    func ready()
    
    func failed(error: Error)
    
    func cancelled()
}

extension SocketServiceDelegate {

    func setup() {
        print("Socket Service:", "setup")
    }
    
    func waiting(error: Error) {
        print("Socket Service:", "waiting", error)
    }
    
    func preparing() {
        print("Socket Service:", "preparing")
    }
    
    func ready() {
        print("Socket Service:", "ready")
    }
    
    func failed(error: Error) {
        print("Socket Service:", "failed", error)
    }
    
    func cancelled() {
        print("Socket Service:", "cancelled")
    }
}
