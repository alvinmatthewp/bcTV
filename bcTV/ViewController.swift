//
//  ViewController.swift
//  bcTV
//
//  Created by alvin.pratama on 28/09/21.
//

import UIKit
import ComposableArchitecture

class ViewController: UIViewController {
    
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

