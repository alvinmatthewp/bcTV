//
//  ViewController.swift
//  bcTV
//
//  Created by alvin.pratama on 28/09/21.
//

import UIKit
import ComposableArchitecture
import Combine
import SuperPlayer

class ViewController: UIViewController {
    
    let indicator = UIImageView()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        return spinner
    }()
    
    lazy var playerControl: CustomPlayerControlView = {
        let control = CustomPlayerControlView(store: store.scope(
            state: \.superPlayerState.control,
            action: AppAction.superPlayerAction
        ))
        
        return control
    }()
    
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment.mock
    )
    
    let progressView = UIProgressView()
    
    lazy var viewStore = ViewStore(self.store)
    var disposeBag = Array<AnyCancellable>()
    let maximumPlayDuration: Double = 20
    let debouncer = Debouncer(timeInterval: 1.5)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleVideo(store: store.scope(
            state: \.superPlayerState,
            action: AppAction.superPlayerAction
        ))

        setupView()
//        setupTouch()
        
        viewStore.send(.loadVideo)

        viewStore.publisher.videoState
            .sink(receiveValue: { [weak self] state in
                self?.handleVideoState(state: state)
            })
            .store(in: &disposeBag)
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    func setupView() {
        indicator.isHidden = true
        
        playerControl.backgroundColor = .black.withAlphaComponent(0.5)
        
        view.addSubview(spinner)
        view.addSubview(indicator)
        view.addSubview(playerControl)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        playerControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 50),
            indicator.heightAnchor.constraint(equalToConstant: 50),
            
            playerControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerControl.heightAnchor.constraint(equalToConstant: CustomPlayerControlView.height)
        ])
    }
    
    func setupTouch() {
        let touchArea = CGSize(width: 80, height: self.view.frame.height)

        let leftView = UIView(frame: CGRect(origin: .zero, size: touchArea))
        let rightView = UIView(frame: CGRect(origin: CGPoint(x: self.view.frame.width - touchArea.width, y: 0), size: touchArea))

        leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftViewTapped)))
        rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightViewTapped)))

        leftView.backgroundColor = .clear
        rightView.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        view.addSubview(leftView)
        view.addSubview(rightView)
    }
    
    func handleVideo(store: Store<SuperPlayerState, SuperPlayerAction>) {
        let superPlayer = SuperPlayerViewController(store: store)
        superPlayer.view.frame = view.frame
        superPlayer.view.backgroundColor = .black
        
        viewStore.publisher.superPlayerState.player.timeControlStatus
            .sink(receiveValue: { [weak self] timeControlStatus in
                if timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    self?.spinner.startAnimating()
                } else {
                    self?.spinner.stopAnimating()
                }
            })
            .store(in: &disposeBag)
        
        addChild(superPlayer)
        view.addSubview(superPlayer.view)
        superPlayer.didMove(toParent: self)
    }
    
    @objc func rightViewTapped() {
        viewStore.send(.forwardVideo)
    }
    
    @objc func leftViewTapped() {
        viewStore.send(.backwardVideo)
    }
    
    @objc func viewTapped() {
        viewStore.send(.handleTapVideo)
    }
    
    func handleVideoState(state: VideoState) {
        guard !spinner.isAnimating, state != .play else { return }
        
        indicator.image = UIImage(named: state.rawValue)
        indicator.isHidden = false
        
        if state != .pause {
            viewStore.send(.videoContinue)
            hideIndicator()
        } else {
            debouncer.stopTimer()
        }
    }
    
    func hideIndicator() {
        debouncer.renewInterval()
        debouncer.handler = { [weak self] in
            self?.indicator.isHidden = true
        }
    }
}

