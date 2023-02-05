//
//  MenuController.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 05.02.2023.
//

import UIKit

private let reuseIdentifier = "MenuCell"

class MenuController: UIViewController {

    //MARK: - Properties
    var tableView = UITableView()

    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = MenuHeader(frame: frame)
        return view
    }()

    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }

    //MARK: - Selectors

    //MARK: - Helper Functions
    private func configureTableView() {
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
        self.view.addSubview(tableView)
    }
}

extension MenuController: UITableViewDelegate, UITableViewDataSource {

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Menu Option"

         return cell
    }
}
