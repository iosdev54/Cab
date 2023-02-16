//
//  AuthButton.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 21.01.2023.
//

import UIKit

class AuthButton: UIButton {
    
    //MARK: - Properties
    private let title: String
    private var spinner = UIActivityIndicatorView()
    var isLoading = false {
        didSet {
            updateView()
        }
    }
    
    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            guard newValue != isHighlighted else { return }
            
            if newValue == true {
                titleLabel?.alpha = 0.25
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.titleLabel?.alpha = 1
                }
                super.isHighlighted = newValue
            }
            super.isHighlighted = newValue
        }
    }
    
    //MARK: - Lifecycle
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Functions
    private func setupView() {
        setTitle(title, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 20)
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = .mainBlueTint
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        spinner.hidesWhenStopped = true
        spinner.color = .white
        spinner.style = .medium
        
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        spinner.centerX(inView: self)
        spinner.centerY(inView: self)
    }
    
    private func updateView() {
        
        if isLoading {
            UIView.animate(withDuration: 0.25) {
                self.spinner.startAnimating()
                self.setTitle("", for: .normal)
                self.isEnabled = false
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.spinner.stopAnimating()
                self.setTitle(self.title, for: .normal)
                self.isEnabled = true
            }
        }
    }
    
}
