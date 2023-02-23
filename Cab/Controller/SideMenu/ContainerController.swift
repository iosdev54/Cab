//
//  ContainerController.swift
//  Cab
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
    
    private let blackView = UIView()
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chechIfUserIsLoggedIn()
//        signOut()
    }
    
    //MARK: - Selectors
    @objc private func dismissMenu() {
        isExpanded = false
        animateMenu(shouldExpend: isExpanded)
    }
    
    //MARK: - API
    private func chechIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginController()
            return
        } else {
            configure()
        }
    }
    
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            presentLoginController()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    //MARK: - Helper Functions
    func configure() {
        view.backgroundColor = .backgroundColor
        configureHomeController()
        fetchUserData()
    }
    
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
        menuController.delegate = self
        
        configureBlackView()
    }
    
    private func presentLoginController() {
        DispatchQueue.main.async {
            let controller = LoginController()
            let nav = CustomNavigationController(rootViewController: controller)
//            let nav = UINavigationController(rootViewController: LoginController())
            nav.isModalInPresentation = true
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    private func configureBlackView() {
        blackView.frame = view.frame
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        homeController.view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    private func animateMenu(shouldExpend: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpend {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80
                self.blackView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
                self.blackView.alpha = 0
            }, completion: completion)
        }
        animateStatusBar()
    }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

//MARK: - SettingsControllerDelegate
extension ContainerController: SettingsControllerDelegate {
   
    func updateUser(_ controller: SettingsController) {
        self.user = controller.user
    }
    
    func deleteUser() {
        print("DEBUG: Container deleteUser")
        menuController.dismiss(animated: true)
        homeController.dismiss(animated: true)
        
        presentLoginController()
        self.presentAlertController(withTitle: "Account deleted!", message: "")
        print("DEBUG: user \(user)")
        
    }
    
}

//MARK: - HomeControllerDelegate
extension ContainerController: HomeControllerDelegate {
    
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpend: isExpanded)
    }
    
}

//MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
    
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpend: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                guard let user = self.user else { return }
                let controller = SettingsController(user: user)
                controller.delegate = self
                let nav = CustomNavigationController(rootViewController: controller)
//                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            case .logout:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
                let logout = UIAlertAction(title: "Log Out", style: .destructive) { _ in
                    self.signOut()
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(logout)
                alert.addAction(cancel)
                self.present(alert, animated: true)
                
                //FIXME: - Fix
//                                self.menuController.view.removeFromSuperview()
            }
        }
    }
    
}
