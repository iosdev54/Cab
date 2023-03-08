//
//  PickupLocationView.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 04.03.2023.
//

import UIKit

protocol PickupLocationViewDelegate: AnyObject {
    func dismissPickupLocationView()
}

class PickupLocationView: UIView {
    
    var address: String = "" {
        didSet {
            doneButton.isEnabled = address == "" ? false : true
            addressLabel.text = address
        }
    }
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .backgroundColor
        return label
    }()
    
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: "Done")
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    weak var delegate: PickupLocationViewDelegate?
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc private func doneButtonPressed() {
        delegate?.dismissPickupLocationView()
    }
    
    //MARK: - Helper functions
    private func setupView() {
        backgroundColor = .mainWhiteTint
        applyShadow()
        
        let stack = UIStackView(arrangedSubviews: [addressLabel, doneButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16, paddingBottom: 16)
    }
    
}
