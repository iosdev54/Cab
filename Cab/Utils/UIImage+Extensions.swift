//
//  UIColor+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 15.02.2023.
//

import UIKit


extension UIImage {
    
    //For Login / Signup Controller
    static let envelopeImage = UIImage(systemName: "envelope")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let personImage = UIImage(systemName: "person")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let lockImage = UIImage(systemName: "lock")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let showPassword = UIImage(systemName: "eye")?.withTintColor(.mainGreenTint, renderingMode: .alwaysOriginal)
    static let hidePassword = UIImage(systemName: "eye.slash")?.withTintColor(.mainGreenTint, renderingMode: .alwaysOriginal)
    
    //For SettingsController / UserProfileHeader
    static let dismiss = UIImage(systemName: "xmark")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let sliderSettings = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let changeData = UIImage(systemName: "pencil")?.withTintColor(.black, renderingMode: .alwaysOriginal)
    static let deleteAccount = UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
}

extension Optional where Wrapped == UIImage {
    
    func unwrapImage() -> UIImage {
        guard let image = self else { return UIImage() }
        return image
    }
}

