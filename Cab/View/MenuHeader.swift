//
//  MenuHeader.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 05.02.2023.
//

import UIKit

class MenuHeader: UIView {
    
    //MARK: - Properties
    private let user: User
    
    private lazy var profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreenTint
        view.setDimensions(height: 64, width: 64)
        view.layer.cornerRadius = 64 / 2
        
        view.addSubview(initialLabel)
        initialLabel.centerX(inView: view)
        initialLabel.centerY(inView: view)
        
        return view
    }()
    
    private lazy var initialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.textColor = .mainWhiteTint
        label.text = user.firstInitial
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()
    
    private lazy var bottomSingleLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreenTint
        view.anchor(height: 1.25)
        return view
    }()
    
    private lazy var pickupModeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var pickupModeSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = true
        s.tintColor = .mainWhiteTint
        s.onTintColor = .mainGreenTint
        s.layer.cornerRadius = s.frame.height / 2
        s.backgroundColor = .lightGray
        s.clipsToBounds = true
        s.addTarget(self, action: #selector(handlePickupModeChanged), for: .valueChanged)
        return s
    }()
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - HelperFunctions
    func setupView() {
        
        let stackUser = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stackUser.axis = .vertical
        stackUser.distribution = .fillEqually
        stackUser.spacing = 4
        stackUser.alignment = .leading
        
        let stackProfile = UIStackView(arrangedSubviews: [profileImageView, stackUser])
        stackProfile.axis = .horizontal
        stackProfile.distribution = .fill
        stackProfile.spacing = 16
        stackProfile.alignment = .center
        
        stackProfile.isLayoutMarginsRelativeArrangement = true
        stackProfile.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let stackMain = UIStackView(arrangedSubviews: [stackProfile])
        stackMain.axis = .vertical
        stackMain.distribution = .fill
        stackMain.spacing = 16
        
        addSubview(stackMain)
        
        //Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Width
        stackMain.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = stackMain.leftAnchor.constraint(equalTo: leftAnchor)
        leftConstraint.priority = .defaultHigh
        
        let topConstraint = stackMain.topAnchor.constraint(equalTo: topAnchor)
        topConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            leftConstraint,
            topConstraint,
            stackMain.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            stackMain.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        if user.accountType == .driver {
            let stackPickup = UIStackView(arrangedSubviews: [pickupModeLabel, pickupModeSwitch])
            stackPickup.axis = .horizontal
            stackPickup.distribution = .fill
            
            stackPickup.isLayoutMarginsRelativeArrangement = true
            stackPickup.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            stackMain.addArrangedSubview(stackPickup)
            
            pickupModeLabel.attributedText = attributtedStringForPickupModeLabel()
        }
        
        stackMain.addArrangedSubview(bottomSingleLine)
        
    }
    
    func attributtedStringForPickupModeLabel() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "PICKUP MODE  ", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.mainWhiteTint])
        if pickupModeSwitch.isOn {
            attributedString.append(NSAttributedString(string: "ENABLED", attributes: [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: UIColor.mainGreenTint]))
        } else {
            attributedString.append(NSAttributedString(string: "DISABLED", attributes: [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: UIColor.red]))
        }
        return attributedString
    }
    
    //MARK: - Selectors
    @objc func handlePickupModeChanged() {
        //FIXME: - handlePickupModeChanged
        pickupModeLabel.attributedText = attributtedStringForPickupModeLabel()
    }
    
}
