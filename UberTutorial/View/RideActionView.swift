//
//  RideActionView.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 28.01.2023.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: AnyObject {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM UBERX"
        case .cancel: return "CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionView: UIView {
    
    //MARK: - Properties
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    var buttonAction = ButtonAction()
    
    weak var delegate: RideActionViewDelegate?
    var user: User?
    
    var config = RideActionViewConfiguration() {
        didSet { configureUI(withConfig: config) }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        //        label.text = "Test Address Title"
        return label
    }()
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        //        label.text = "123 M St, NW Washington DC"
        return label
    }()
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.text = "X"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    private let uberInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = "UberX"
        return label
    }()
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBER X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: self.topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        infoView.centerX(inView: self)
        infoView.anchor(top: addressLabel.bottomAnchor, paddingTop: 16)
        
        addSubview(uberInfoLabel)
        uberInfoLabel.centerX(inView: self)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        
        let sepparatorView = UIView()
        sepparatorView.backgroundColor = .lightGray
        
        addSubview(sepparatorView)
        sepparatorView.anchor(top: uberInfoLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, right: rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, paddingLeft: 12, paddingRight: 12, paddingBottom: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc private func actionButtonPressed() {
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirections:
            print("DEBUG: Handle getDirections...")
        case .pickup:
            print("DEBUG: Handle pickup...")
        case .dropOff:
            print("DEBUG: Handle dropOff...")
        }
    }
    
    //MARK: - Helper functions
    private func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else { return }
            if user.accountType == .passenger {
                titleLabel.text = "En Route To Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                titleLabel.text = "Driver En Route"
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
            
        case .pickupPassenger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = user else { return }
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "En Route to Destination"
        case .endTrip:
            guard let user = user else { return }
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVER TO DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        }
    }
    
}
