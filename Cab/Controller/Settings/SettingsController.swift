//
//  SettingsController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 07.02.2023.
//

import UIKit

private let reuseIdentifier = "FavoritesCell"

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home: return "Add Home"
        case .work: return "Add  Work"
        }
    }
}

protocol SettingsControllerDelegate: AnyObject {
    func updateUser(_ controller: SettingsController)
    func deleteUser()
}

class SettingsController : UIViewController {
    
    //MARK: - Properties
    var user: User
    private let tableView = UITableView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private lazy var userProfileHeader: UserProfileHeader = {
        let view = UserProfileHeader(user: user)
        view.delegate = self
        return view
    }()
    
    weak var delegate: SettingsControllerDelegate?
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColor
        configureTableView()
        configureNavigatoionBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        autoLayoutHeaderView()
    }
    
    //MARK: - Selectors
    @objc private func handleDismissal() {
        dismiss(animated: true)
    }
    
    //MARK: - Helper Functions
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .mainGreenTint
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(FavoritesCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.sectionHeaderTopPadding = 10
        tableView.tableHeaderView = userProfileHeader
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
    }
    
    private func configureNavigatoionBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.mainGreenTint]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.mainGreenTint]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: AppImages.dismissIcon.unwrapImage.editedImage(tintColor: .mainWhiteTint, scale: .large), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
    private func locationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
    private func autoLayoutHeaderView() {
        guard let headerView = self.tableView.tableHeaderView else { return }
        
        let width = self.tableView.bounds.size.width
        let size = headerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FavoritesCell
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(forType: type)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = locationManager?.location else { return }
        let controller = AddLocationController(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.textColor = .lightGray
        title.text = "Favorites"
        
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 20, paddingRight: 16)
        
        return view
    }
    
}

//MARK: - AddLocationControllerDelegate
extension SettingsController: AddLocationControllerDelegate {
    
    func updateLocation(locationString: String, type: LocationType) {
        PassengerService.shared.saveLocation(locationString: locationString, type: type) { [weak self] err, ref in
            guard let`self` = self else { return }
            self.dismiss(animated: true)
            
            switch type {
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            self.delegate?.updateUser(self)
            self.tableView.reloadData()
        }
    }
    
}

//MARK: - UserProfileHeaderDelegate
extension SettingsController: UserProfileHeaderDelegate {
    func handleChangeData() {
        print("DEBUG: handleChangeData")
    }
    
    func handleDeleteAccount() {
        
        presentAlertController(withTitle: "Are you sure you want to delete your account?", message: "All your data will be deleted.", actionName: "Delete") { _ in
            Service.shared.deleteAccount { [weak self] error in
                guard let `self` = self else { return }
                if let error {
                    self.presentAlertController(withTitle: "Oops!", message: "Deletion error, \(error.localizedDescription)")
                } else {
                    self.delegate?.deleteUser()
                }
            }
        }
    }
    
}
