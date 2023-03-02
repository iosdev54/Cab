//
//  CustomButton.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 21.01.2023.
//

import UIKit

class CustomButton: UIButton {
    
    //MARK: - Properties
    private let title: String
    private let spinner = UIActivityIndicatorView()
    var isLoading = false {
        didSet {
            updateView()
        }
    }
    private let animationDuration = 0.25
    
    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            guard newValue != isHighlighted else { return }
            
            if newValue == true {
                titleLabel?.alpha = 0.25
            } else {
                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let `self` = self else { return }
                    self.titleLabel?.alpha = 1
                }
                super.isHighlighted = newValue
            }
            super.isHighlighted = newValue
        }
    }
    
    override var isEnabled: Bool {
        get { return super.isEnabled }
        set {
            guard newValue != isEnabled else { return }
            
            if newValue == true {
                alpha = 1
            } else {
                alpha = 0.5
            }
            super.isEnabled = newValue
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
        setTitleColor(UIColor.mainWhiteTint, for: .normal)
        backgroundColor = .mainGreenTint
        layer.cornerRadius = 5
        anchor(height: 40)
        
        spinner.hidesWhenStopped = true
        spinner.color = .mainWhiteTint
        spinner.style = .medium
        
        addSubview(spinner)
        spinner.centerX(inView: self)
        spinner.centerY(inView: self)
    }
    
    private func updateView() {
        
        if isLoading {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let `self` = self else { return }
                self.spinner.startAnimating()
                self.setTitle("", for: .normal)
                self.isEnabled = false
            }
        } else {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let `self` = self else { return }
                self.spinner.stopAnimating()
                self.setTitle(self.title, for: .normal)
                self.isEnabled = true
            }
        }
    }
    
}
