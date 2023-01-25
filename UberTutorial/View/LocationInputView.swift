//
//  LocationInputView.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 23.01.2023.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    
    func dismissLocationInputView()
}

class LocationInputView: UIView {
    
    //MARK: - Properties
    weak var delegate: LocationInputViewDelegate?
    
    var user: User? {
        didSet { titleLabel.text = user?.fullname }
    }
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startingLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current location"
        tf.backgroundColor = .systemGroupedBackground
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isEnabled = false
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination..."
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 24, height: 24)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(top: startingLocationTextField.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.centerY(inView: startingLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        destinationIndicatorView.centerY(inView: destinationLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)

        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor, paddingTop: 4, paddingBottom: 4, width: 0.5)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc private func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
    
}
