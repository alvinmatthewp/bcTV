//
//  AppReducer.swift
//  bcTV
//
//  Created by alvin.pratama on 28/09/21.
//

import Foundation
import ComposableArchitecture
import SuperPlayer

struct AppState: Equatable {
    var superPlayerState: SuperPlayerState = .init()
    var mediaURLString: String = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    var isPause: Bool = false
}

enum AppAction: Equatable {
    case loadVideo
    case handleTapVideo
    case playVideo
    case pauseVideo
    
    case superPlayerAction(SuperPlayerAction)
}

struct AppEnvironment {}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    superPlayerReducer
        .pullback(
            state: \.superPlayerState,
            action: /AppAction.superPlayerAction,
            environment: { _ in SuperPlayerEnvironment.live() }
        ),
    Reducer { state, action, env in
        switch action {
        case .loadVideo:
            state.isPause = false
            return Effect(value: .superPlayerAction(.load(URL(string: state.mediaURLString)!, autoPlay: true)))
            
        case .handleTapVideo:
            state.isPause = !state.isPause
            return state.isPause ? Effect(value: .pauseVideo) : Effect(value: .playVideo)
            
        case .playVideo:
            return Effect(value: .superPlayerAction(.player(.callMethod(.play))))
            
        case .pauseVideo:
            return Effect(value: .superPlayerAction(.player(.callMethod(.pause))))
            
        default:
            return .none
        }
    }
)
