//
//  UIView+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 22.02.2023.
//

import UIKit

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingRight: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0, rightAnchor: NSLayoutXAxisAnchor? = nil, paddingRight: CGFloat = 0, constants: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constants).isActive = true
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
        if let right = rightAnchor {
            anchor(right: right, paddingRight: paddingRight)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func applyShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
    
    func makeCorner(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        //        layer.isOpaque = false
    }
    
    var selectedBackgroundView: UIView {
        get {
            let view = UIView()
            view.backgroundColor = .mainGreenTint.withAlphaComponent(0.5)
            return view
        }
    }
    
    //    func inputContainerView(leftImage: UIImage, rightImage: UIImage, textField: UITextField) -> UIView {
    //        let view = UIView()
    //
    //        let leftImageView = UIImageView()
    //        leftImageView.image = leftImage
    //        leftImageView.contentMode = .scaleAspectFit
    //        view.addSubview(leftImageView)
    //        leftImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, width: 40)
    //        leftImageView.backgroundColor = .red
    //
    //        let rightImageView = UIImageView()
    //        rightImageView.image = rightImage
    //        rightImageView.contentMode = .scaleAspectFit
    //        rightImageView.isUserInteractionEnabled = true
    //        view.addSubview(rightImageView)
    //        rightImageView.anchor(top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, paddingTop: 0, paddingRight: 0, paddingBottom: 0, width: 60)
    //        rightImageView.backgroundColor = .red
    //
    //        view.addSubview(textField)
    //        textField.anchor(top: view.topAnchor, left: leftImageView.rightAnchor, right: rightImageView.leftAnchor, bottom: view.bottomAnchor, paddingLeft: 10, paddingRight: 10)
    //
    //        let rightImageViewTap = UIGestureRecognizer(target: self, action: #selector(handleRightImageTap))
    //        rightImageView.addGestureRecognizer(rightImageViewTap)
    //
    //        view.makeCorner(cornerRadius: 5)
    //        view.layer.borderColor = UIColor.backgroundColor.cgColor
    //        view.layer.borderWidth = 0.75
    //
    //        return view
    //    }
    //
    //
    //    @objc private func handleRightImageTap() {
    //        print("DEBUG: Opapa")
    //    }
    
}
