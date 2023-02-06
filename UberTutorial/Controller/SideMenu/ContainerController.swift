//
//  ContainerController.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 05.02.2023.
//

import UIKit
import FirebaseAuth

class ContainerController: UIViewController {
    
    //MARK: - Properties
    private let homeController = HomeController()
    private var menuController: MenuController!
    private var isExpanded: Bool = false
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColor
        configureHomeController()
        fetchUserData()
    }
    
    //MARK: - Selectors
    
    //MARK: - API
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    //MARK: - Helper Functions
    private func configureHomeController() {
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
    }
    
    private func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
    }
    
    private func animateMenu(shouldExpend: Bool) {
        if shouldExpend {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.homeController.view.frame.origin.x = 0
            }
        }
    }
    
}

extension ContainerController: HomeControllerDelegate {
    
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpend: isExpanded)
        
    }
    
}
