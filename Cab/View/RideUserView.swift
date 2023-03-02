//
//  RideUserView.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 28.02.2023.
//

import UIKit

class RideUserView: UIView {
    
    //MARK: - Properties
    var user: User? {
        didSet {
            initialLabel.text = user?.firstInitial
            fullnameLabel.text = user?.fullname
        }
    }
    
    private let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreenTint
        return view
    }()
    
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.textAlignment = .center
        label.textColor = .mainWhiteTint
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .backgroundColor
        return label
    }()
    
    //MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    //MARK: - HelperFunctions
    func setupView() {
        profileImageView.setDimensions(height: 64, width: 64)
        
        profileImageView.addSubview(initialLabel)
        initialLabel.centerX(inView: profileImageView)
        initialLabel.centerY(inView: profileImageView)
        
        let stackProfile = UIStackView(arrangedSubviews: [profileImageView, fullnameLabel])
        stackProfile.axis = .vertical
        stackProfile.distribution = .fill
        stackProfile.spacing = 10
        stackProfile.alignment = .center
        
        addSubview(stackProfile)
        stackProfile.centerX(inView: self)
        stackProfile.centerY(inView: self)
    }
    
}
