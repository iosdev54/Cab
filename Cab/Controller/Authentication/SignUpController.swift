//
//  SignUpController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 21.01.2023.
//

import UIKit
import GeoFire

class SignUpController: UIViewController {
    
    //MARK: - Properties
    private var location = LocationHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CAB"
        label.font = UIFont(name: "Avenir-light", size: 36)
        label.textAlignment = .center
        label.textColor = .mainWhiteTint
        return label
    }()
    
    private lazy var emailTextField: CustomTextField = {
        return CustomTextField(config: .autorization, placeholder: "Email", leftImage: AppImages.envelopeImageIcon.unwrapImage.editedImage(tintColor: .mainWhiteTint, scale: .large), keyboardType: .emailAddress)
    }()
    
    private lazy var fullNameTextField: CustomTextField = {
        return CustomTextField(config: .autorization, placeholder: "Name", leftImage: AppImages.personImageIcon.unwrapImage.editedImage(tintColor: .mainWhiteTint, scale: .large), keyboardType: .alphabet)
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        return CustomTextField(config: .autorization, placeholder: "Password", leftImage: AppImages.lockImageIcon.unwrapImage.editedImage(tintColor: .mainWhiteTint, scale: .large), keyboardType: .default, isSecureTextEntry: true, rightButtonAction: .password)
    }()
    
    private lazy var accountTypeSegmentedControl: AccountTypeSegmentedControl = {
        return AccountTypeSegmentedControl(items: ["Passenger", "Driver"])
    }()
    
    private lazy var signUpButton: AuthButton = {
        let button = AuthButton(title: "Sign Up")
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.mainWhiteTint])
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.mainGreenTint]))
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureUI()
    }
    
    //MARK: - Selectors
    @objc private func handleSignUp() {
        signUpButton.isLoading = true
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let fullname = fullNameTextField.text
        else { return }
        
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        if fullname.count < 6 || email.isEmpty || password.isEmpty {
            self.presentAlertController(withTitle: "Oops!", message: "Please enter a valid email, password and name, at least 6 characters.")
            signUpButton.isLoading = false
            return
        }
        
        Service.shared.signUp(withEmail: email, password: password) { [weak self] result, error in
            guard let `self` = self else { return }
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
                Service.shared.deleteAccount { [weak self] error in
                    guard let `self` = self else { return }
                    if let error = error {
                        self.signUpButton.isLoading = false
                        self.presentAlertController(withTitle: "Oops!", message: "Registration failed, \(error.localizedDescription)")
                    } else {
                        self.signUpButton.isLoading = false
                        self.presentAlertController(withTitle: "Oops!", message: "Registration failed. Try to register later.")
                    }
                }
            }
            guard let controller = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first?.rootViewController as? ContainerController else { return }
            controller.configure()
            self.dismiss(animated: true)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        emailTextField.delegate = self
        fullNameTextField.delegate = self
        passwordTextField.delegate = self
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, passwordTextField, accountTypeSegmentedControl])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 25, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.view.tintColor = .mainGreenTint
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "")
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension SignUpController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
