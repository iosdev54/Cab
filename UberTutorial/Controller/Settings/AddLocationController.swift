//
//  AddLocationController.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 07.02.2023.
//

import UIKit

private let reuseIdentifier = "Cell"

class AddLocationController: UIViewController {
    
    //MARK: - Properties
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
    }
    
    //MARK: - Helper Functions
    private func configureTableView() {
        //        tableView.delegate = self
        //        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        //        tableView.addShadow()
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
    }
    
    private func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.backgroundColor = .backgroundColor
        searchBar.searchTextField.backgroundColor = .white
        navigationItem.titleView = searchBar
    }
    
}

//MARK: - UISearchBarDelegate
extension AddLocationController: UISearchBarDelegate {
    
}
