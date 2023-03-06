//
//  CustomTextField.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 24.02.2023.
//

import UIKit

protocol CustomTextFieldDelegate: AnyObject {
    func setCurrentLocation()
}

enum CustomTextFieldConfiguration {
    case autorization
    case location
}

enum CustomTextFieldButtonAction {
    case password
    case currentLocation
}

class CustomTextField: UITextField {
    
    //MARK: - Properties
    private let config: CustomTextFieldConfiguration
    private let leftImage: UIImage
    
    private var containerSize: CGFloat = 40
    
    private lazy var rightButton: UIButton = UIButton(type: .custom)
    private let rightButtonAction: CustomTextFieldButtonAction?
    
    weak var myDelegate: CustomTextFieldDelegate?
    
    //MARK: - Lifecycle
    init(config: CustomTextFieldConfiguration, placeholder: String, leftImage: UIImage,  keyboardType: UIKeyboardType = .default, isSecureTextEntry: Bool = false, backgroundColor: UIColor? = nil, rightButtonAction: CustomTextFieldButtonAction? = nil) {
        self.config = config
        self.leftImage = leftImage
        self.rightButtonAction = rightButtonAction
        
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
        self.backgroundColor = backgroundColor
        
        configureTextField()
        setLeftIcon()
        setRightButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Function
    private func configureTextField() {
        borderStyle = .none
        layer.borderWidth = 0.75
        layer.cornerRadius = 5
        font = .systemFont(ofSize: 16)
        anchor(height: containerSize)
        
        switch config {
        case .autorization:
            layer.borderColor = UIColor.borderTint
            textColor = .white
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [.foregroundColor : UIColor.lightGray])
            keyboardAppearance = .dark
            
        case .location:
            layer.borderColor = UIColor.backgroundColor.cgColor
            textColor = .black
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [.foregroundColor : UIColor.darkGray])
            keyboardAppearance = .light
            returnKeyType = .search
        }
    }
    
    private func setLeftIcon() {
        let frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        let iconView = UIImageView(frame: frame)
        iconView.image = leftImage
        iconView.contentMode = .center
        let iconContainerView: UIView = UIView(frame: frame)
        iconContainerView.addSubview(iconView)
        leftViewMode = .always
        leftView = iconContainerView
    }
    
    private func setRightButton() {
        
        switch rightButtonAction {
        case .password:
            let frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
            rightButton.frame = frame
            rightButton.setImage(AppImages.showPasswordIcon.unwrapImage.editedImage(tintColor: .mainGreenTint, scale: .medium), for: .normal)
            rightButton.setImage(AppImages.hidePasswordIcon.unwrapImage.editedImage(tintColor: .mainGreenTint, scale: .medium), for: .selected)
            rightButton.contentMode = .center
            rightButton.alpha = 0.7
            rightButton.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
            let iconContainerView: UIView = UIView(frame: frame)
            iconContainerView.addSubview(rightButton)
            rightViewMode = .always
            rightView = iconContainerView
            
        case .currentLocation:
            let frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
            rightButton.frame = frame
            rightButton.setImage(AppImages.changeLocationIcon.unwrapImage.editedImage(tintColor: .mainGreenTint, scale: .large), for: .normal)
            rightButton.contentMode = .center
            rightButton.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
            let iconContainerView: UIView = UIView(frame: frame)
            iconContainerView.addSubview(rightButton)
            rightViewMode = .unlessEditing
            rightView = iconContainerView
        case .none:
            break
        }
    }
    
    @objc private func handleButtonAction() {
        
        switch rightButtonAction {
        case .password:
            togglePasswordVisibility()
        case .currentLocation:
            myDelegate?.setCurrentLocation()
        default: break
        }
    }
    
    private func togglePasswordVisibility() {
        isSecureTextEntry.toggle()
        rightButton.isSelected.toggle()
        
        if let existingText = text, isSecureTextEntry {
            /* When toggling to secure text, all text will be purged if the user
             continues typing unless we intervene. This is prevented by first
             deleting the existing text and then recovering the original text. */
            deleteBackward()
            
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
        
        /* Reset the selected text range since the cursor can end up in the wrong
         position after a toggle because the text might vary in width */
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
    
}
