//
//  RideActionView.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 28.01.2023.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: AnyObject {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
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
    case tripInProgress
    case pickup
    case dropOff
    case tripIsOver
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM RIDE"
        case .cancel: return "CANCEL RIDE"
        case .tripInProgress: return "TRIP IN PROGRESS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        case .tripIsOver: return "TRIP IS OVER"
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
    
    var user: User? {
        didSet {
            rideUserView.user = user
        }
    }
    
    var config = RideActionViewConfiguration() {
        didSet { configureUI(withConfig: config) }
    }
    
    private var buttonAction = ButtonAction()
    
    weak var delegate: RideActionViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .backgroundColor
        return label
    }()
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()
    
    private let rideUserView = RideUserView()
    
    private(set) lazy var yellowTaxiAnimationView: UIView = {
        let view = addLottieAnimation(withName: "yellow-taxi", height: 150, animationSpeed: 0.5)
        view.flipX()
        return view
    }()
    
    private(set) lazy var thanksAnimationView: UIView = {
        return addLottieAnimation(withName: "thanks", height: 170, animationSpeed: 0.35)
    }()
    
    private(set) lazy var actionButton: AuthButton = {
        let button = AuthButton(title: ButtonAction.requestRide.description)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private var rideUserStack = UIStackView()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
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
        case .pickup:
            delegate?.pickupPassenger()
        case .dropOff:
            delegate?.dropOffPassenger()
        default: break
        }
    }
    
    //MARK: - Helper functions
    private func setupView() {
        backgroundColor = .mainWhiteTint
        applyShadow()
        
        let topStack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        topStack.axis = .vertical
        topStack.spacing = 4
        topStack.alignment = .center
        topStack.distribution = .fill
        
        rideUserStack = UIStackView(arrangedSubviews: [rideUserView])
        rideUserStack.axis = .vertical
        rideUserStack.alignment = .center
        rideUserStack.distribution = .fill
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, rideUserStack, actionButton])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16, paddingBottom: 16)
    }
    
    private func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            changeSubviewInStack(inStack: rideUserStack, view: yellowTaxiAnimationView, at: 0)
            actionButton.setTitle(buttonAction.description, for: .normal)
            actionButton.isEnabled = true
        case .tripAccepted:
            guard let user = user else { return }
            if user.accountType == .passenger {
                titleLabel.text = "En route to passenger"
                addressLabel.text = "Pick up the passenger at the pickup location"
                buttonAction = .tripInProgress
                actionButton.setTitle(buttonAction.description, for: .normal)
                actionButton.isEnabled = false
            } else {
                changeSubviewInStack(inStack: rideUserStack, view: rideUserView, at: 0)
                titleLabel.text = "Driver en route"
                addressLabel.text = "Wait for the driver at the pickup location"
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                actionButton.isEnabled = true
            }
        case .driverArrived:
            titleLabel.text = "Driver has arrived"
            addressLabel.text = "Driver is waiting for you"
            
        case .pickupPassenger:
            titleLabel.text = "Arrived at the passenger location"
            addressLabel.text = "Wait for the passenger"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            actionButton.isEnabled = true
        case .tripInProgress:
            guard let user = user else { return }
            titleLabel.text = "En route to destination"
            addressLabel.text = ""
            if user.accountType == .driver {
                buttonAction = .tripInProgress
                actionButton.setTitle(buttonAction.description, for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                actionButton.isEnabled = true
            }
        case .endTrip:
            guard let user = user else { return }
            titleLabel.text = "Arrival at destination"
            if user.accountType == .driver {
                changeSubviewInStack(inStack: rideUserStack, view: thanksAnimationView, at: 0)
                buttonAction = .tripIsOver
                actionButton.setTitle(buttonAction.description, for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
                actionButton.isEnabled = true
            }
            
        }
    }
    
    private func changeSubviewInStack(inStack stack: UIStackView, view: UIView, at stackIndex: Int) {
        if let subview = stack.arrangedSubviews.first {
            subview.removeFromSuperview()
        }
        stack.insertArrangedSubview(view, at: stackIndex)
    }
    
}
