//
//  SettingsController.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 07.02.2023.
//

import UIKit

private let reuseIdentifier = "LocationCell"

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

class SettingsController : UIViewController {
    
    //MARK: - Properties
    private let user: User
    
    private let tableView = UITableView()
    
    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        return view
    }()
    
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
        
        configureTableView()
        configureNavigatoionBar()
    }
    
    //MARK: - Selectors
    @objc private func handleDismissal() {
        dismiss(animated: true)
    }
    
    //MARK: - Helper Functions
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableHeaderView = infoHeader
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
    }
    
    private func configureNavigatoionBar() {
        //        view.backgroundColor = .backgroundColor
        //        navigationController?.navigationBar.prefersLargeTitles = true
        //        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        //        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        //        navigationItem.title = "Settings"
        //
        //        navigationController?.navigationBar.tintColor = .white
        //        navigationController?.navigationBar.barTintColor = .backgroundColor
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "baseline_clear_white_36pt_2x")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
        
        //Second way
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barTintColor = .backgroundColor //Doesn't work
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "baseline_clear_white_36pt_2x")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        guard let type = LocationType(rawValue: indexPath.row) else { return cell}
        cell.type = type
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16)
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        let controller = AddLocationController()
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
}
