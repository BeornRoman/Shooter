//
//  GameInteractor.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import UIKit

final class GameInteractor {
    
    // MARK: - Internal Properties

    private var viewModel: GameViewModel {
        didSet {
            presenter.viewController?.update(viewModel: viewModel)
        }
    }
    
    // MARK: - Private Properties

    private let presenter: GamePresenter
    
    private let socketService: SocketServiceProtocol
    
    private var data: GameViewData = .init(frame: .zero)
    
    private var isAppeared: Bool = false

    init(presenter: GamePresenter, socketService: SocketServiceProtocol, viewModel: GameViewModel) {
        self.presenter = presenter
        self.socketService = socketService
        self.viewModel = viewModel
        socketService.delegate = self
    }
    
    func viewDidLoad() {
        presenter.update(viewModel: viewModel)
    }
    
    func viewDidAppear(data: GameViewData) {
        guard !isAppeared else { return }
        isAppeared = true
        self.data = data
    }
    
    func move(side: String) {
        send(key: "move", params: [side])
    }

    func connect() {
        try? socketService.connect()
    }
    
    func disconnect() {
        try? socketService.disconnect()
    }
}

extension GameInteractor: SocketServiceDelegate {
    
    func recieved(message: String) {
        let parts = message.components(separatedBy: ":")
        let key = parts[0]
        let components = parts[1].components(separatedBy: ",")
        switch key {
        case "enemyConnected": handleEnemyConnection(components: components)
        case "enemyDisconnected": handleEnemyDisconnection(components: components)
        case "enemyPosition": handleEnemyPosition(components: components)
        case "myPosition": handleMyPosition(components: components)
        default: return
        }
    }
    
    func preparing() {
        print("Socket Service:", "preparing")
        presenter.hideMe()
        presenter.hideEnemy()
        viewModel.connectButton.isEnabled = false
        viewModel.disconnectButton.isEnabled = false
    }
    
    func waiting(error: Error) {
        print("Socket Service:", "waiting", error)
        presenter.hideMe()
        presenter.hideEnemy()
        viewModel.connectButton.isEnabled = true
        viewModel.disconnectButton.isEnabled = false
    }
    
    func ready() {
        print("Socket Service:", "ready")
        viewModel.connectButton.isEnabled = false
        viewModel.disconnectButton.isEnabled = true
        
        send(key: "data", params: [
            Player.username,
            data.frame.origin.x.description,
            data.frame.origin.y.description,
            data.frame.width.description,
            data.frame.height.description
        ])
    }
    
    func cancelled() {
        print("Socket Service:", "cancelled")
        presenter.hideMe()
        presenter.hideEnemy()
        viewModel.connectButton.isEnabled = true
        viewModel.disconnectButton.isEnabled = false
    }
    
    func failed(error: Error) {
        print("Socket Service:", "failed", error)
        presenter.hideMe()
        presenter.hideEnemy()
        viewModel.connectButton.isEnabled = true
        viewModel.disconnectButton.isEnabled = false
    }
}

private extension GameInteractor {
    
    func send(key: String, params: [String]) {
        let data = (key + ":" + params.joined(separator: ",")).data(using: .utf8)!
        try? socketService.send(message: data)
    }
    
    func handleEnemyConnection(components: [String]) {
        guard let x = Float(components[1]), let y = Float(components[2]) else {
            print("Bad coordinates")
            return
        }
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        presenter.showEnemy(position: point)
    }
    
    func handleEnemyDisconnection(components: [String]) {
        presenter.hideEnemy()
    }
    
    func handleEnemyPosition(components: [String]) {
        guard let x = Float(components[1]), let y = Float(components[2]) else {
            print("Bad coordinates")
            return
        }
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        presenter.showEnemy(position: point)
    }
    
    func handleMyPosition(components: [String]) {
        guard let x = Float(components[1]), let y = Float(components[2]) else {
            print("Bad coordinates")
            return
        }
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        presenter.showMy(position: point)
    }
}
