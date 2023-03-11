//
//  UserProfileHeader.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 07.02.2023.
//

import UIKit

protocol UserProfileHeaderDelegate: AnyObject {
    func handleChangeData()
    func handleDeleteAccount()
}

class UserProfileHeader: UIView {
    
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
    
    private lazy var accountSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AppImages.sliderSettingsIcon.unwrapImage.editedImage(tintColor: .mainWhiteTint, scale: .large), for: .normal)
        button.menu = showMenu()
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private lazy var topSingleLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreenTint
        view.anchor(height: 1.25)
        return view
    }()
    
    private lazy var bottomSingleLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreenTint
        view.anchor(height: 1.25)
        return view
    }()
    
    weak var delegate: UserProfileHeaderDelegate?
    
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
        
        let stackProfile = UIStackView(arrangedSubviews: [profileImageView, stackUser, accountSettingsButton])
        stackProfile.axis = .horizontal
        stackProfile.distribution = .fill
        stackProfile.spacing = 16
        stackProfile.alignment = .center
        
        stackProfile.isLayoutMarginsRelativeArrangement = true
        stackProfile.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let stackMain = UIStackView(arrangedSubviews: [topSingleLine, stackProfile, bottomSingleLine])
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
            stackMain.rightAnchor.constraint(equalTo: rightAnchor),
            stackMain.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func showMenu() -> UIMenu {
        let changeData = UIAction( title: "Change data", image: AppImages.changeDataIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .default)) { [weak self] _ in
            self?.delegate?.handleChangeData()
        }
        let deleteAccount = UIAction( title: "Delete account", image: AppImages.deleteAccountIcon.unwrapImage.editedImage(tintColor: .mapIconTint, scale: .default)) { [weak self] _ in
            self?.delegate?.handleDeleteAccount()
        }
        let menuActions = [changeData, deleteAccount]
        let menu = UIMenu( title: "", children: menuActions)
        
        return menu
    }
    
}
