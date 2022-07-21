//
//  SocketServiceProtocol.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import Foundation

protocol SocketServiceProtocol: AnyObject {
    
    var delegate: SocketServiceDelegate? { get set }
    
    func connect() throws
    
    func send(message content: Data) throws

    func disconnect() throws
}
