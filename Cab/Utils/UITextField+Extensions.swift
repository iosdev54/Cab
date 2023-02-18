//
//  UITextField+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 15.02.2023.
//

import UIKit

extension UITextField {
        
    func inputTextField(withImage image: UIImage?, placeholder: String, keyboardType: UIKeyboardType, isSecureTextEntry: Bool) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.layer.borderColor = UIColor.borderTint
        tf.layer.borderWidth = 0.75
        tf.layer.cornerRadius = 5
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor.lightGray])
        tf.keyboardAppearance = .dark
        tf.keyboardType = keyboardType
        tf.isSecureTextEntry = isSecureTextEntry
        tf.setIcon(withImage: image, padding: 20)
        tf.anchor(height: 40)
        
        return tf
    }
    
    func setIcon(withImage image: UIImage?, padding: CGFloat) {
        guard let image = image else { return }
        let frame = CGRect(x: 0, y: 0, width: image.size.width + padding, height: image.size.height)
        let iconView = UIImageView(frame: frame)
        iconView.image = image
        iconView.contentMode = .center
        let iconContainerView: UIView = UIView(frame: frame)
        iconContainerView.addSubview(iconView)
        leftViewMode = .always
        leftView = iconContainerView
    }
    
    func setButton(withImage image: UIImage?, textField: UITextField, padding: CGFloat, completion: @escaping (UIButton) -> Void) {
        guard let image = image else { return }
        let frame = CGRect(x: 0, y: 0, width: image.size.width + 20, height: image.size.height)
        let button = UIButton(frame: frame)
        button.setImage(image, for: .normal)
        button.contentMode = .center
        completion(button)
        let iconContainerView: UIView = UIView(frame: frame)
        iconContainerView.addSubview(button)
        textField.rightViewMode = .always
        textField.rightView = iconContainerView
    }
        
}
