//
//  UIView+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 22.02.2023.
//

import UIKit

extension UIView {
    
    var selectedBackgroundView: UIView {
        get {
            let view = UIView()
            view.backgroundColor = .mainGreenTint.withAlphaComponent(0.5)
            return view
        }
    }
    
}
