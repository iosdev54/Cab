//
//  UIColor+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 15.02.2023.
//

import UIKit

enum AppImages {
    //For LoginController / SignUpController
    static let envelopeImageIcon = UIImage(systemName: "envelope")
    static let personImageIcon = UIImage(systemName: "person")
    static let lockImageIcon = UIImage(systemName: "lock")
    static let showPasswordIcon = UIImage(systemName: "eye")
    static let hidePasswordIcon = UIImage(systemName: "eye.slash")
    
    //For HomeController / LocationInputView
    static let menuIcon = UIImage(named: "menu")
    static let backIcon = UIImage(systemName: "arrow.backward")
    static let changeLocationIcon = UIImage(systemName: "location.magnifyingglass")
    static let mappinIcon = UIImage(systemName: "mappin")
    static let mapIcon = UIImage(systemName: "map")
    static let taxiIcon = UIImage(named: "taxi")
    
    //For SettingsController / UserProfileHeader
    static let dismissIcon = UIImage(systemName: "xmark")
    static let sliderSettingsIcon = UIImage(systemName: "slider.horizontal.3")
    static let changeDataIcon = UIImage(systemName: "pencil")
    static let deleteAccountIcon = UIImage(systemName: "trash")
}


extension UIImage {
    
    func editedImage(tintColor: UIColor, scale: SymbolScale) -> UIImage {
        let editedImage = self.withTintColor(tintColor, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(scale: scale))
        return editedImage
    }
    
}

extension Optional where Wrapped == UIImage {
    
    var unwrapImage: UIImage {
        guard let image = self else { return UIImage() }
        return image
    }
    
}
