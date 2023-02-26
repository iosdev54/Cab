//
//  LocationInputView.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 23.01.2023.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {
    
    //MARK: - Properties
    var user: User? {
        didSet { titleLabel.text = user?.fullname }
    }
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AppImages.backIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .large), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .backgroundColor
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var startingLocationTextField: CustomTextField = {
        let tf = CustomTextField(config: .location, placeholder: "Change current location", leftImage: AppImages.mappinIcon.unwrapImage.editedImage(tintColor: .mapIconColor, scale: .large), keyboardType: .alphabet, backgroundColor: .systemGroupedBackground, rightButtonAction: .currentLocation)
        tf.delegate = self
        tf.myDelegate = self
        return tf
    }()
    
    private lazy var destinationLocationTextField: CustomTextField = {
        let tf = CustomTextField(config: .location, placeholder: "Enter a destination", leftImage: AppImages.mapIcon.unwrapImage.editedImage(tintColor: .mapIconColor, scale: .large), keyboardType: .alphabet)
        tf.delegate = self
        return tf
    }()
    
    weak var delegate: LocationInputViewDelegate?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .mainWhiteTint
        applyShadow()
        
        addSubview(backButton)
        backButton.anchor(left: leftAnchor, paddingLeft: 16, width: 32, height: 32)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        let stack = UIStackView(arrangedSubviews: [startingLocationTextField, destinationLocationTextField])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16
        
        addSubview(stack)
        stack.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: 10, paddingLeft: 16, paddingRight: 16, paddingBottom: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc private func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
}

//MARK: - UITextFieldDelegate
extension LocationInputView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == startingLocationTextField {
            //FIXME: - startingLocationTextField
            print("DEBUG: startingLocationTextField")
            textField.resignFirstResponder()
        }
        if textField == destinationLocationTextField {
            guard let query = textField.text else { return false }
            delegate?.executeSearch(query: query)
            textField.resignFirstResponder()
            return true
        }
        return false
    }
}

//MARK: - CustomTextFieldDelegate
extension LocationInputView: CustomTextFieldDelegate {
    func chooseCurrentLocation() {
        //FIXME: - chooseCurrentLocation
        print("DEBUG: Choose current location.")
    }
    
}
