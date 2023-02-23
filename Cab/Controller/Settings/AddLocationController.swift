//
//  AddLocationController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 07.02.2023.
//

import UIKit
import MapKit

private let reuseIdentifier = "Cell"

protocol AddLocationControllerDelegate: AnyObject {
    func updateLocation(locationString: String, type: LocationType)
}

class AddLocationController: UIViewController {
    
    //MARK: - Properties
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet {
            tableView.reloadData()
        }
    }
    private let type: LocationType
    private let location: CLLocation
    private let regionInMetters = 2_000.00
    
    weak var delegate: AddLocationControllerDelegate?
    
    //MARK: - Lifecycle
    
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
    }
    
    //MARK: - Helper Functions
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .mainWhiteTint
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 50
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
    }
    
    private func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.backgroundColor = .backgroundColor
        searchBar.placeholder = "Enter the name or address of the location"
        searchBar.searchTextField.backgroundColor = .mainWhiteTint
        navigationItem.titleView = searchBar
    }
    
    private func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionInMetters, longitudinalMeters: regionInMetters)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddLocationController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        cell.backgroundColor = .clear
        let result = searchResults[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = result.title
        content.secondaryText = searchResults[indexPath.row].subtitle
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = searchResults[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        let locationString = title + " " + subtitle
        let trimmedLocation = locationString.replacingOccurrences(of: ", England", with: "")
        delegate?.updateLocation(locationString: trimmedLocation, type: type)
    }
    
}

//MARK: - UISearchBarDelegate
extension AddLocationController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        
        if searchText == "" { searchResults.removeAll() }
    }
    
}

//MARK: - MKLocalSearchCompleterDelegate
extension AddLocationController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
}
