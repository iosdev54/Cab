//
//  PickupController.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 30.01.2023.
//

import UIKit
import MapKit

class PickupController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    let trip: Trip
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_clear_white_36pt_2x")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this passenger?"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    private lazy var acceptTripButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Selectors
    @objc private func handleDismissal() {
        dismiss(animated: true)
    }
    @objc private func handleAcceptTrip() {
        print("DEBUG: Accept trip here...")
    }
    
    //MARK: - API
    
    //MARK: - Helper Functions
    private func configureUI() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270 / 2
        
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constants: -200)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
    
}
