//
//  AppReducer.swift
//  bcTV
//
//  Created by alvin.pratama on 28/09/21.
//

import Foundation
import ComposableArchitecture

struct AppState: Equatable {}

enum AppAction: Equatable {}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
    return .none
}
