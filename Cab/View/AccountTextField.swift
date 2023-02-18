//
//  AccountTextField.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 17.02.2023.
//

import UIKit

class AccountTextField: UITextField {
    
    //MARK: - Properties
    private let leftImage: UIImage
    private let placeholderString: String
    private let typeOfKeyboard: UIKeyboardType
    private let isSecureText: Bool
    private var isRightButton: Bool
    
    private let containerSize: CGFloat = 40
    private lazy var rightButton: UIButton = UIButton(type: .custom)
    
    //MARK: - Lifecycle
    init(leftImage: UIImage, placeholderString: String, typeOfKeyboard: UIKeyboardType, isSecureText: Bool = false, isRightButton: Bool = false) {
        self.leftImage = leftImage
        self.placeholderString = placeholderString
        self.typeOfKeyboard = typeOfKeyboard
        self.isSecureText = isSecureText
        self.isRightButton = isRightButton
        
        super.init(frame: .zero)
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
        layer.borderColor = UIColor.borderTint
        layer.borderWidth = 0.75
        layer.cornerRadius = 5
        font = .systemFont(ofSize: 16)
        textColor = .white
        attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [.foregroundColor : UIColor.lightGray])
        keyboardAppearance = .dark
        keyboardType = typeOfKeyboard
        isSecureTextEntry = isSecureText
        anchor(height: containerSize)
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
        if isRightButton {
            let frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
            rightButton.frame = frame
            rightButton.setImage(UIImage.showPassword.unwrapImage(), for: .normal)
            rightButton.setImage(UIImage.hidePassword.unwrapImage(), for: .selected)
            rightButton.contentMode = .center
            rightButton.alpha = 0.7
            rightButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
            let iconContainerView: UIView = UIView(frame: frame)
            iconContainerView.addSubview(rightButton)
            rightViewMode = .always
            rightView = iconContainerView
        }
    }
    
    @objc private func togglePasswordVisibility() {
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
