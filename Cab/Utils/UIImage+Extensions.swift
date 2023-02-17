//
//  UIColor+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 15.02.2023.
//

import UIKit


extension UIImage {
    
    static let envelopeImage = UIImage(systemName: "envelope")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    static let personImage = UIImage(systemName: "person")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    static let lockImage = UIImage(systemName: "lock")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    static let personFill = UIImage(systemName: "person.crop.square.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    static let showPassword = UIImage(systemName: "eye")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    static let hidePassword = UIImage(systemName: "eye.slash")?.withTintColor(.white, renderingMode: .alwaysOriginal)
}

