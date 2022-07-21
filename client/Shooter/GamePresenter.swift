//
//  GamePresenter.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import UIKit

final class GamePresenter {
    
    weak var viewController: GameViewController?
    
    func showEnemy(position: CGPoint) {
        viewController?.showEnemy(position: position)
    }
    
    func showMy(position: CGPoint) {
        viewController?.showMy(position: position)
    }
    
    func hideEnemy() {
        viewController?.hideEnemy()
    }
    
    func hideMe() {
        viewController?.hideMe()
    }
    
    func update(viewModel: GameViewModel) {
        viewController?.update(viewModel: viewModel)
    }
}
