//
//  PickupController.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 30.01.2023.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: AnyObject {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    var trip: Trip
    private var isAccepted = false
    weak var delegate: PickupControllerDelegate?
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cpv = CircularProgressView(frame: frame)
        
        cpv.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268 / 2
        mapView.centerX(inView: cpv)
        mapView.centerY(inView: cpv, constants: 32)
        return cpv
    }()
    
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
        configureMapView()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Selectors
    @objc private func handleDismissal() {
        dismiss(animated: true)
    }
    @objc private func handleAcceptTrip() {
        isAccepted = true
        DriverService.shared.acceptTrip(trip: trip) { [weak self] err, reff in
            guard let `self` = self else { return }
            self.trip.state = .accepted
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    @objc private func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 10, value: 0) {
            guard self.isAccepted == false else { return }
            DriverService.shared.updateTripState(trip: self.trip, state: .denied) { [weak self] err, ref in
                guard let `self` = self else { return }
                self.dismiss(animated: true)
            }
        }
    }
    
    //MARK: - Helper Functions
    private func configureUI() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 32)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
    private func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        
        //Second way
        //        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        //        mapView.showAnnotations([annotation], animated: true)
    }
    
    
}
