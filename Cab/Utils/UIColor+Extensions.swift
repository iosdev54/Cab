//
//  UIColor+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 16.02.2023.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 47, green: 53, blue: 66)
    static let mainGreenTint = UIColor.rgb(red: 46, green: 213, blue: 115)
    static let borderTint = UIColor.rgb(red: 255, green: 255, blue: 255).cgColor
    static let mainWhiteTint = UIColor.rgb(red: 255, green: 255, blue: 255)
    static let mapIconColor = UIColor.rgb(red: 255, green: 75, blue: 79)
    
    //Colors for animating CircularProgressView
    static let outlineStrokeColor = UIColor.rgb(red: 234, green: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, green: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, green: 30, blue: 63)
}
