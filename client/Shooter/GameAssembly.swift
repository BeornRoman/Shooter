//
//  GameAssembly.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import UIKit

struct GameAssembly {
    
    static func build() -> UIViewController {
        let url = URL(string: "ws://127.0.0.1:8080/ws")!
        let socketService = SocketService(url: url)
        let viewModel = GameViewModel(connectButton: .init(title: "Connect", isEnabled: true), disconnectButton: .init(title: "Disconnect", isEnabled: false))
        let presenter = GamePresenter()
        let interactor = GameInteractor(presenter: presenter, socketService: socketService, viewModel: viewModel)
        let viewController = GameViewController(interactor: interactor)
        presenter.viewController = viewController
        return viewController
    }
}
