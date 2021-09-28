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
    
    lazy var indicator: UIImageView = {
        let image = UIImageView()
        image.indicatorStyle()
        image.centerInParent(parent: self.view)
        return image
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.centerInParent(parent: self.view)
        return spinner
    }()
    
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment.mock
    )
    
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
        setupTouch()
        
        viewStore.send(.loadVideo)

        
        viewStore.publisher.videoState
            .sink(receiveValue: { [weak self] state in
                self?.handleVideoState(state: state)
            })
            .store(in: &disposeBag)
    }
    
    func setupView() {
        view.addSubview(spinner)
        view.addSubview(indicator)
        
        indicator.isHidden = true
    }
    
    func setupTouch() {
        let touchArea = CGSize(width: 80, height: self.view.frame.height)

        let leftView = UIView(frame: CGRect(origin: .zero, size: touchArea))
        let rightView = UIView(frame: CGRect(origin: CGPoint(x: self.view.frame.width - touchArea.width, y: 0), size: touchArea))

        leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftViewTapped)))
        rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightViewTapped)))

        leftView.backgroundColor = .clear
        rightView.backgroundColor = .clear

        self.view.addSubview(leftView)
        self.view.addSubview(rightView)
    }
    
    func handleVideo(store: Store<SuperPlayerState, SuperPlayerAction>) {
        let superPlayer = SuperPlayerViewController(store: store)
        superPlayer.view.frame = view.frame
        superPlayer.view.backgroundColor = .black
        superPlayer.view.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoTapped))
        superPlayer.view.addGestureRecognizer(tapGesture)
        
        viewStore.publisher.superPlayerState.player.timeControlStatus
            .sink(receiveValue: { [weak self] timeControlStatus in
                if timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    self?.spinner.startAnimating()
                    tapGesture.isEnabled = false
                } else {
                    self?.spinner.stopAnimating()
                    tapGesture.isEnabled = true
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
    
    @objc func videoTapped() {
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

