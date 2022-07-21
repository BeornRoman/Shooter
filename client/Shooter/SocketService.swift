//
//  SocketService.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import Foundation
import Network

enum SocketServiceError: String, Error {
    
    case noConnection
}

final class SocketService {
    
    // MARK: - SocketServiceProtocol Properties

    weak var delegate: SocketServiceDelegate?
    
    // MARK: - Private Properties
    
    private let url: URL

    private var connection: NWConnection?
    
    private let queue = DispatchQueue(label: "hostname")
    
    private var parameters: NWParameters {
        let object: NWParameters = .tcp
        object.allowLocalEndpointReuse = true
        object.includePeerToPeer = true
        object.defaultProtocolStack.applicationProtocols.insert(options, at: 0)
        return object
    }
    
    private var options: NWProtocolWebSocket.Options {
        let object = NWProtocolWebSocket.Options()
        object.maximumMessageSize = 1024
        return object
    }
    
    private var newConnection: NWConnection {
        let object = NWConnection(to: .url(url), using: parameters)
        let stateUpdateHandler = self.stateUpdateHandler
        object.stateUpdateHandler = stateUpdateHandler
        return object
    }
    
    init(url: URL) {
        self.url = url
    }
    
    deinit {
        try? disconnect()
    }
}

// MARK: - SocketServiceProtocol

extension SocketService: SocketServiceProtocol {
    
    func connect() throws {
        try? disconnect()
        connection = newConnection
        connection?.start(queue: queue)
        try recieve()
    }

    func send(message content: Data) throws {
        guard let connection = connection else { throw SocketServiceError.noConnection }
        let message = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "text", metadata: [message])
        let completion: NWConnection.SendCompletion = .contentProcessed(sendCallback)
        connection.send(content: content, contentContext: context, completion: completion)
    }

    func disconnect() throws {
        guard let connection = connection else { throw SocketServiceError.noConnection }
        connection.cancel()
    }
}

private extension SocketService {
    
    func recieve() throws {
        guard let connection = connection else { throw SocketServiceError.noConnection }
        let completion = self.recieveCallback
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024, completion: completion)
    }
    
    func recieveCallback(_ content: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: NWError?) {
        if let error = error {
            print("Debug:", error.localizedDescription)
            return
        }
        guard let content = content, let message = String(data: content, encoding: .utf8) else {
            print("Debug:", "No Content")
            return
        }
        print("Recieved:", message)
        DispatchQueue.main {
            self.delegate?.recieved(message: message)
        }
        do {
            try recieve()
        } catch {
            print("Debug:", error.localizedDescription)
        }
    }
    
    func sendCallback(_ error: NWError?) {
        if let error = error {
            print("Debug:", error.localizedDescription)
            return
        }
        print("Sended")
    }
    
    func stateUpdateHandler(state: NWConnection.State) {
        DispatchQueue.main {
            switch state {
            case .setup: self.delegate?.setup()
            case .waiting(let error): self.delegate?.waiting(error: error)
            case .preparing: self.delegate?.preparing()
            case .ready: self.delegate?.ready()
            case .failed(let error): self.delegate?.failed(error: error)
            case .cancelled: self.delegate?.cancelled()
            default:
                return
            }
        }
    }
}
