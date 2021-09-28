//
//  UIImageView+Extension.swift
//  bcTV
//
//  Created by alvin.pratama on 28/09/21.
//

import UIKit

extension UIImageView {
    func centerImage(size: CGSize = CGSize(width: 15, height: 15), parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
}
