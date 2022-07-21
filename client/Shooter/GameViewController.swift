//
//  GameView.swift
//  Shooter
//
//  Created by Roman Matveev on 20.07.2022.
//

import Foundation
import UIKit

final class GameViewController: UIViewController {

    // MARK: - Private Properties

    private let interactor: GameInteractor
    
    private lazy var shootingArea: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        return view
    }()
    
    private let myBox: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen.withAlphaComponent(0.9)
        view.isHidden = true
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        view.layer.cornerRadius = 20
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = .init(width: 0, height: 6)
        return view
    }()
    
    private let enemyBox: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed.withAlphaComponent(0.9)
        view.isHidden = true
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        view.layer.cornerRadius = 20
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = .init(width: 0, height: 6)
        return view
    }()
    
    private lazy var timer = Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    
    private var touchSide: String?
    
    private lazy var connectButton = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(connect))
    private lazy var disconnectButton = UIBarButtonItem(title: "Disconnect", style: .plain, target: self, action: #selector(disconnect))

    init(interactor: GameInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = "Shooter"
        navigationItem.setRightBarButton(connectButton, animated: true)
        navigationItem.setLeftBarButton(disconnectButton, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        interactor.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .tertiarySystemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .tertiarySystemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGrid()
        let data = GameViewData(
            frame: shootingArea.frame
        )
        interactor.viewDidAppear(data: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder: is not implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let position = touches.first?.location(in: shootingArea) else { return }
        if position.x > view.bounds.size.width / 2 {
            touchSide = "right"
        } else {
            touchSide = "left"
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchSide = nil
    }
    
    func showEnemy(position: CGPoint) {
        enemyBox.isHidden = false
        enemyBox.layer.position = position
    }
    
    func showMy(position: CGPoint) {
        myBox.isHidden = false
        myBox.layer.position = position
    }

    func hideEnemy() {
        enemyBox.isHidden = true
    }
    
    func hideMe() {
        myBox.isHidden = true
    }
    
    func update(viewModel: GameViewModel) {
        connectButton.title = viewModel.connectButton.title
        connectButton.isEnabled = viewModel.connectButton.isEnabled
        disconnectButton.title = viewModel.disconnectButton.title
        disconnectButton.isEnabled = viewModel.disconnectButton.isEnabled
    }
}

private extension GameViewController {
    
    @objc func connect() {
        interactor.connect()
    }
    
    @objc func disconnect() {
        interactor.disconnect()
    }

    @objc func tick() {
        switch touchSide {
        case "right":
            interactor.move(side: "right")
        case "left":
            interactor.move(side: "left")
        default:
            return
        }
    }

    func setupUserInterface() {
        view.backgroundColor = .white
        view.addSubview(shootingArea)
        shootingArea.addSubview(myBox)
        shootingArea.addSubview(enemyBox)
    }
    
    func setupGrid() {
        shootingArea.frame = view.safeAreaLayoutGuide.layoutFrame
        timer.fire()
    }
}
