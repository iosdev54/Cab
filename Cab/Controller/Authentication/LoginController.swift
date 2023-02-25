//
//  LoginController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 20.01.2023.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    
    //MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CAB"
        label.font = UIFont(name: "Avenir-light", size: 36)
        label.textAlignment = .center
        label.textColor = .mainWhiteTint
        return label
    }()
    
    private lazy var emailTextField: CustomTextField = {
        return CustomTextField(config: .autorization, placeholder: "Email", leftImage: UIImage.envelopeImageIcon.unwrapImage(), keyboardType: .emailAddress)
    }()
    
    private lazy var passwordTextField: CustomTextField = {
        return CustomTextField(config: .autorization, placeholder: "Password", leftImage: UIImage.lockImageIcon.unwrapImage(), keyboardType: .default, isSecureTextEntry: true, rightButtonAction: .password)
    }()
    
    private lazy var loginButton: AuthButton = {
        let button = AuthButton(title: "Log In")
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        return button
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account  ", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.mainWhiteTint])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.mainGreenTint]))
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Selectors
    @objc private func handleLogIn() {
        loginButton.isLoading = true
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Service.shared.logIn(withEmail: email, password: password) { [weak self] result, error in
            guard let `self` = self else { return }
            if let error = error {
                self.presentAlertController(withTitle: "Oops!", message: error.localizedDescription)
                self.loginButton.isLoading = false
                return
            }
            guard let controller = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first?.rootViewController as? ContainerController else { return }
            //Old record
            //            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? ContainerController else { return }
            controller.configure()
            self.dismiss(animated: true)
        }
    }
    
    @objc private func handleShowSignUp() {
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - Helper Functions
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: navigationController?.navigationBar.frame.height ?? 0)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 25, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(loginButton)
        loginButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
}

//MARK: - UITextFieldDelegate
extension LoginController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
