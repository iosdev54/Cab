//
//  UITextField+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 15.02.2023.
//

import UIKit

extension UITextField {
    
    func inputTextField(withImage image: UIImage?, placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.layer.borderColor = UIColor.borderColor
        tf.layer.borderWidth = 0.75
        tf.layer.cornerRadius = 5
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor.lightGray])
        tf.keyboardAppearance = .dark
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
}
