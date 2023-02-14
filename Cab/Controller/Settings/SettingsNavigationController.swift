//
//  SettingsNavigationController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 07.02.2023.
//

import UIKit

class SettingsNavigationController: UINavigationController {
    
    let navController = UINavigationController()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
    
}
