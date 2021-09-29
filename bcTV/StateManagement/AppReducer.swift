//
//  AppReducer.swift
//  bcTV
//
//  Created by alvin.pratama on 28/09/21.
//

import Foundation
import ComposableArchitecture
import SuperPlayer

enum VideoState: String {
    case play = "play"
    case pause = "pause"
    case resume = "resume"
    case forward = "forward"
    case backward = "backward"
    case end = "end"
}

struct AppState: Equatable {
    var superPlayerState: SuperPlayerState = .init()
    var videoState: VideoState = .play
}

enum AppAction: Equatable {
    case loadVideo
    case handleTapVideo
    case resumeVideo
    case pauseVideo
    case forwardVideo
    case backwardVideo
    case endVideo
    case videoContinue
    
    case superPlayerAction(SuperPlayerAction)
}

struct AppEnvironment {
    var getVideoURLString: () -> String
    
    static var mock = AppEnvironment(
        getVideoURLString: {
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        }
    )
}

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
            state.videoState = .play
            return Effect(value: .superPlayerAction(.load(URL(string: env.getVideoURLString())!, autoPlay: true)))
            
        case .handleTapVideo:
            return state.videoState != .pause ? Effect(value: .pauseVideo) : Effect(value: .resumeVideo)
            
        case .resumeVideo:
            state.videoState = .resume
            return Effect(value: .superPlayerAction(.player(.callMethod(.play))))
            
        case .pauseVideo:
            state.videoState = .pause
            return Effect(value: .superPlayerAction(.player(.callMethod(.pause))))
            
        case .forwardVideo:
            guard state.videoState == .play else {
                return state.videoState == .pause ? Effect(value: .resumeVideo) : .none
            }
            
            state.videoState = .forward
            return Effect(value: .superPlayerAction(.forward(by: 15)))
            
        case .backwardVideo:
            guard state.videoState == .play else {
                return state.videoState == .pause ? Effect(value: .resumeVideo) : .none
            }
            
            state.videoState = .backward
            return Effect(value: .superPlayerAction(.backward(by: 15)))
            
        case .videoContinue:
            state.videoState = .play
            return .none
            
        default:
            return .none
        }
    }
)
