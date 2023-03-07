//
//  MenuController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 05.02.2023.
//

import UIKit

private let reuseIdentifier = "MenuCell"

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips: return "Your Trips"
        case .settings: return "Settings"
        case .logout: return "Log Out"
        }
    }
}

protocol MenuControllerDelegate: AnyObject {
    func didSelect(option: MenuOptions)
}

class MenuController: UIViewController {
    
    //MARK: - Properties
    var user: User? {
        didSet {
            guard let user else { return }
            tableView.tableHeaderView = MenuHeader(user: user)
        }
    }
    private let tableView = UITableView()
    
    private let menuFooter: UIView = {
        return UIView().addLottieAnimation(withName: "green-search-annimation", height: 150, animationSpeed: 0.5)
    }()
    
    weak var delegate: MenuControllerDelegate?
    
    //MARK: - Lyfecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        autoLayoutHeaderView()
        adjustFooterViewHeightToFillTableView()
    }
    
    //MARK: - Helper Functions
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .mainGreenTint
        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = menuFooter
        
        self.view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, paddingRight: 80 - 10)
    }
    
    func autoLayoutHeaderView() {
        guard let headerView = tableView.tableHeaderView else { return }
        
        let width = tableView.bounds.size.width
        let size = headerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
        }
    }
    
    func adjustFooterViewHeightToFillTableView() {
        guard let tableFooterView = tableView.tableFooterView else { return }
        
        let minHeight = tableFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let currentFooterHeight = tableFooterView.frame.height
        let fitHeight = tableView.frame.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom - tableView.contentSize.height + currentFooterHeight
        let nextHeight = (fitHeight > minHeight) ? fitHeight : minHeight
        
        guard round(nextHeight) != round(currentFooterHeight) else { return }
        
        var frame = tableFooterView.frame
        frame.size.height = nextHeight
        tableFooterView.frame = frame
        tableView.tableFooterView = tableFooterView
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MenuController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.selectedBackgroundView = UIView().selectedBackgroundView
        cell.backgroundColor = .clear
        
        guard let option = MenuOptions(rawValue: indexPath.row) else { return UITableViewCell()}
        
        var content = cell.defaultContentConfiguration()
        content.text = option.description
        content.textProperties.color = .mainWhiteTint
        content.textProperties.font = UIFont.systemFont(ofSize: 18)
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let option = MenuOptions(rawValue: indexPath.row) else { return }
        delegate?.didSelect(option: option)
    }
    
}
