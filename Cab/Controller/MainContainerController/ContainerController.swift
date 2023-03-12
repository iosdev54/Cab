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
    private var homeController: HomeController? = nil
    private var menuController: MenuController? = nil
    
    private var user: User? {
        didSet {
            guard let user, let homeController, let menuController else { return }
            homeController.user = user
            menuController.user = user
        }
    }
    
    private var isExpanded: Bool = false
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
        
        view.backgroundColor = .backgroundColor
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
        Service.shared.fetchUserData(uid: currentUid) { [weak self] user in
            self?.user = user
        }
    }
    
    private func signOut() {
        Service.shared.signOut { [weak self] in
            self?.presentLoginController()
            self?.dismissChildController(homeController)
            self?.dismissChildController(menuController)
            
            self?.homeController = nil
            self?.menuController = nil
            self?.user = nil
        }
    }
    
    //MARK: - Helper Functions
    func configure() {
        configureHomeController()
        configureMenuController()
        fetchUserData()
    }
    
    private func configureHomeController() {
        homeController = HomeController()
        guard let homeController else { return }
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
    }
    
    private func configureMenuController() {
        menuController = MenuController()
        guard let menuController else { return }
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.delegate = self
        
        configureBlackView()
    }
    
    private func presentLoginController() {
        DispatchQueue.main.async { [weak self] in
            let loginController = LoginController()
            let navigationController = CustomNavigationController(rootViewController: loginController)
            navigationController.isModalInPresentation = true
            navigationController.modalPresentationStyle = .fullScreen
            self?.present(navigationController, animated: true)
        }
    }
    
    private func configureBlackView() {
        guard let homeController else { return }
        blackView.frame = view.frame
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        homeController.view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    private func animateMenu(shouldExpend: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpend {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
                guard let `self` = self else { return }
                self.homeController?.view.frame.origin.x = self.view.frame.width - 80
                self.homeController?.inputActivationView.isUserInteractionEnabled = false
                self.homeController?.inputActivationView.alpha = 0.7
                self.blackView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [weak self] in
                self?.homeController?.view.frame.origin.x = 0
                self?.homeController?.inputActivationView.isUserInteractionEnabled = true
                self?.homeController?.inputActivationView.alpha = 1
                self?.blackView.alpha = 0
            }, completion: completion)
        }
        animateStatusBar()
    }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func dismissChildController(_ controller: UIViewController?) {
        guard let controller else { return }
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
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
        
        animateMenu(shouldExpend: isExpanded) { [weak self] _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                guard let user = self?.user else { return }
                let settingsController = SettingsController(user: user)
                settingsController.delegate = self
                let navigationController = CustomNavigationController(rootViewController: settingsController)
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true)
            case .logout:
                self?.presentAlertController(withTitle: "Are you sure you want to log out?", actionName: "Log Out") { [weak self] _ in
                    self?.signOut()
                }
            }
        }
    }
    
}

//MARK: - SettingsControllerDelegate
extension ContainerController: SettingsControllerDelegate {
    func updateUser(withUser user: User) {
        self.user = user
    }
    
    func deleteUser() {
        signOut()
        //FIXME: - Add a func to remove a user and his data from Firebase
        self.presentAlertController(withTitle: "Account deleted!")
    }
    
}
