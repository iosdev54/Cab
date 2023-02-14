//
//  SignUpController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 21.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GeoFire

class SignUpController: UIViewController {
    
    //MARK: - Properties
    private var location = LocationHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        guard let image = UIImage(named: "ic_mail_outline_white_2x") else { return UIView() }
        return UIView().inputContainerView(image: image, textField: emailTextField)
    }()
    private lazy var fullNameContainerView: UIView = {
        guard let image = UIImage(named: "ic_person_outline_white_2x") else { return UIView() }
        return UIView().inputContainerView(image: image, textField: fullNameTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
        guard let image = UIImage(named: "ic_lock_outline_white_2x") else { return UIView() }
        return UIView().inputContainerView(image: image, textField: passwordTextField)
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        guard let image = UIImage(named: "ic_account_box_white_2x") else { return UIView() }
        return UIView().inputContainerView(image: image, segmentedControl: accountTypeSegmentedControl)
    }()
    
    private lazy var emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private lazy var fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Fullname", isSecureTextEntry: false)
    }()
    
    private lazy var passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private lazy var accountTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Rider", "Driver"])
        segmentedControl.backgroundColor = .backgroundColor
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(white: 1, alpha: 0.87)], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentedControl.layer.borderWidth = 0.75
        segmentedControl.layer.borderColor = UIColor.lightGray.cgColor
        return segmentedControl
    }()
    
    private lazy var signUpButton: AuthButton = {
        let button = AuthButton(title: "Log In")
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.mainBlueTint]))
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        configureUI()
    }
    
    //MARK: - Selectors
    @objc func handleSignUp() {
        signUpButton.isLoading = true
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullNameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        if fullname.count < 6 || email.isEmpty || password.isEmpty {
            self.presentAlertController(withTitle: "Oops!", message: "Please enter a valid email, password and name, at least 6 characters.")
            signUpButton.isLoading = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.presentAlertController(withTitle: "Oops!", message: error.localizedDescription)
                self.signUpButton.isLoading = false
                return
            }
            guard let uid = result?.user.uid else { return }
            let values = ["email": email,
                          "fullname": fullname,
                          "accountType": accountTypeIndex]
            
            if accountTypeIndex == 1 {
                if let location = self.location {
                    let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                    geofire.setLocation(location, forKey: uid) { error in
                        self.uploadUserDataAndShowHomeController(uid: uid, values: values)
                        return
                    }
                }
            }
            self.uploadUserDataAndShowHomeController(uid: uid, values: values)
        }
    }
    
    @objc private func handleShowLogIn() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helper Functions
    private func uploadUserDataAndShowHomeController(uid: String, values: [String: Any]) {
        REF_USERS.child(uid).updateChildValues(values) { error, ref in
            if error != nil {
                let user = Auth.auth().currentUser
                self.signUpButton.isLoading = false
                
                user?.delete { error in
                    if let error = error {
                        self.presentAlertController(withTitle: "Oops!", message: "Registration failed. \(error.localizedDescription)")
                        // An error happened.
                    } else {
                        // Account deleted.
                        self.presentAlertController(withTitle: "Oops!", message: "Account deleted.")
                    }
                }
            }
                            print("DEBUG: Successfully register user and saved data")
            guard let controller = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first?.rootViewController as? ContainerController else { return }
            controller.configure()
            self.dismiss(animated: true)
        }
    }
    
    private func configureUI() {
        configureNavBar()
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, fullNameContainerView, passwordContainerView, accountTypeContainerView, signUpButton])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.view.tintColor = .mainBlueTint
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "")
        }
    }
    
}
