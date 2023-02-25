//
//  UIColor+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 15.02.2023.
//

import UIKit


extension UIImage {
    
    //For Login / Signup Controller
    static let envelopeImageIcon = UIImage(systemName: "envelope")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let personImageIcon = UIImage(systemName: "person")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let lockImageIcon = UIImage(systemName: "lock")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let showPasswordIcon = UIImage(systemName: "eye")?.withTintColor(.mainGreenTint, renderingMode: .alwaysOriginal)
    static let hidePasswordIcon = UIImage(systemName: "eye.slash")?.withTintColor(.mainGreenTint, renderingMode: .alwaysOriginal)
    
    //For HomeController / LocationInputView
    static let backIcon = UIImage(systemName: "arrow.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal)
    static let changeLocationIcon = UIImage(systemName: "location.magnifyingglass")?.withTintColor(.mainGreenTint, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(scale: .large))
    static let mappinIcon = UIImage(systemName: "mappin")?.withTintColor(.mapIconColor, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(scale: .large))
    static let mapIcon = UIImage(systemName: "map")?.withTintColor(.mapIconColor, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(scale: .large))

    //For SettingsController / UserProfileHeader
    static let dismissIcon = UIImage(systemName: "xmark")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let sliderSettingsIcon = UIImage(systemName: "slider.horizontal.3")?.withTintColor(.mainWhiteTint, renderingMode: .alwaysOriginal)
    static let changeDataIcon = UIImage(systemName: "pencil")?.withTintColor(.black, renderingMode: .alwaysOriginal)
    static let deleteAccountIcon = UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
}

extension Optional where Wrapped == UIImage {
    
    func unwrapImage() -> UIImage {
        guard let image = self else { return UIImage() }
        return image
    }
}

