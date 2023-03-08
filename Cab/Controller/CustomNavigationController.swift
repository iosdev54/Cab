//
//  CustomNavigationController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 07.02.2023.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    private let navController = UINavigationController()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
    
}
