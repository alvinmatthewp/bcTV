//
//  ViewController.swift
//  bcTV
//
//  Created by alvin.pratama on 28/09/21.
//

import UIKit
import ComposableArchitecture
import SuperPlayer

class ViewController: UIViewController {
    
    let videoWrapper = UIView()
    let playIndicator = UIImageView(image: UIImage(named: "play"))
    let pauseIndicator = UIImageView(image: UIImage(named: "pause"))
    
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment()
    )
    
    lazy var viewStore = ViewStore(self.store)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        handleVideo(
            store: store.scope(
                state: \.superPlayerState,
                action: AppAction.superPlayerAction
            )
        )
        
        viewStore.send(.loadVideo)
    }
    
    func setupView() {
        videoWrapper.frame = self.view.frame
        view.addSubview(videoWrapper)
        
        view.addSubview(playIndicator)
        view.addSubview(pauseIndicator)
        playIndicator.centerImage(parent: self.view)
        pauseIndicator.centerImage(parent: self.view)
        
        playIndicator.isHidden = true
        pauseIndicator.isHidden = true
    }
    
    func handleVideo(store: Store<SuperPlayerState, SuperPlayerAction>) {
        let superPlayer = SuperPlayerViewController(store: store)
        superPlayer.view.frame = videoWrapper.frame
        superPlayer.view.backgroundColor = .black
        superPlayer.view.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap))
        superPlayer.view.addGestureRecognizer(tapGesture)
        
        addChild(superPlayer)
        videoWrapper.addSubview(superPlayer.view)
    }
    
    @objc func handleVideoTap(_ sender: UITapGestureRecognizer) {
        viewStore.send(.handleTapVideo)
        if viewStore.state.isPause {
            playIndicator.isHidden = true
            pauseIndicator.isHidden = false
        } else {
            playIndicator.isHidden = false
            pauseIndicator.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.playIndicator.isHidden = true
            }
        }
        
    }
}

