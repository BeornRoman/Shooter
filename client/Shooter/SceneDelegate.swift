//
//  SceneDelegate.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let rootViewController = GameAssembly.build()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    
//    static var window: UIWindow {
//        
//    }
}
