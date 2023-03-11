//
//  HomeController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 22.01.2023.
//

import UIKit
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

private enum ActionButonConfiguration {
    case showMenu
    case dismissActionView
    case dissmissPickupLocationView
    
    init() {
        self = .showMenu
    }
}

enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeControllerDelegate: AnyObject {
    func handleMenuToggle()
}

class HomeController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    
    private let locationManager = LocationHandler.shared.locationManager
    private lazy var mapManager = MapManager(mapView: mapView)
    private var inputActivationView = LocationInputActivationView()
    private let locationInpitView = LocationInputView()
    private let rideActionView = RideActionView()
    private let pickupLocationView = PickupLocationView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var savedLocations = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    
    private var route: MKRoute?
    
    private lazy var pickupPlacemark: CLPlacemark? = nil {
        didSet {
            pickupLocationView.address = setupStartingLocationText(withPlacemark: pickupPlacemark)
            locationInpitView.startingLocationTextField.text = setupStartingLocationText(withPlacemark: pickupPlacemark)
        }
    }
    private var enableSetPickupCoordinates = false
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            locationInpitView.user = user
            if user.accountType == .passenger {
                fetchDrivers()
                configureInputActivationView()
                observeCurentTrip()
            } else {
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user,user.accountType == .driver else { return }
            guard let trip = trip, trip.state == .requested else { return }
            let controller = PickupController(trip: trip)
            controller.delegate = self
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
    
    private lazy var showUserLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AppImages.location.unwrapImage.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(showUserLocationHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AppImages.menuIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .default), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var pinImage: UIImageView = {
        let imageView = UIImageView(image: AppImages.pin.unwrapImage.editedImage(tintColor: .mapIconTint, scale: .large))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var actionButtonConfig = ActionButonConfiguration()
    
    weak var delegate: HomeControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Selectors
    @objc private func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            delegate?.handleMenuToggle()
        case .dismissActionView:
            mapManager.removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            configureActionButton(config: .showMenu)
            animateRideActionView(shouldShow: false)
            showInputActivationView()
        case .dissmissPickupLocationView:
            configureActionButton(config: .showMenu)
            pickupPlacemark = nil
            showChangePickupLocationUI(shouldShow: false)
            
        }
    }
    
    @objc func showUserLocationHandler() {
        mapManager.showUserLocation() { [weak self] in
            self?.presentAlertController(withTitle: "Oops!", message: "Current location not found.")
        }
    }
    
    @objc func doneButtonPressed() {
        showChangePickupLocationUI(shouldShow: false)
    }
    
    //MARK: - Passenger API
    private func observeCurentTrip() {
        PassengerService.shared.observeCurrentTrip { [weak self] trip in
            guard let state = trip.state, let driverUid = trip.driverUid else { return }
            self?.trip = trip
            
            switch state {
            case .requested:
                break
                
            case .denied:
                self?.shouldPresentLoadingView(false)
                self?.presentAlertController(withTitle: "Oops!", message: "Looks like we couldn't find a driver for you. Please try again.")
                
                PassengerService.shared.deleteTrip { [weak self] _, _ in
                    self?.mapManager.removeAnnotationsAndOverlays()
                    self?.mapManager.showUserLocation()
                    self?.configureActionButton(config: .showMenu)
                    self?.showInputActivationView()
                }
            case .accepted:
                self?.shouldPresentLoadingView(false)
                self?.mapManager.removeAnnotationsAndOverlays()
                self?.mapManager.zoomForActiveTrip(driverUid: driverUid)
                
                Service.shared.fetchUserData(uid: driverUid) { [weak self] driver in
                    guard let `self` = self else { return }
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
                
            case .driverArrived:
                self?.rideActionView.config = .driverArrived
                
            case .inProgress:
                self?.mapManager.removeDriverAnnotations()
                self?.startTrip()
                
            case .danger:
                self?.presentAlertController(withTitle: "Trip is over!", message: "You are behaving inappropriately.")
                self?.mapManager.removeDriverAnnotations()
                self?.deleteTrip()
                
            case .arriveAtDestination:
                self?.rideActionView.config = .endTrip
                
            case .completed:
                self?.presentAlertController(withTitle: "Trip is over!", message: "We hope you enjoyed your trip.")
                self?.deleteTrip()
            }
        }
    }
    
    private func startTrip() {
        guard let user = user, let trip = trip else { return }
        if user.accountType == .driver {
            DriverService.shared.updateTripState(trip: trip, state: .inProgress) { _, _ in
            }
        }
        rideActionView.config = .tripInProgress
        mapManager.removeAnnotationsAndOverlays()
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinates, title: "Destination")
        
        let pickupPlacemark = MKPlacemark(coordinate: trip.destinationCoordinates)
        let pickupMapItem = MKMapItem(placemark: pickupPlacemark)
        let destinationPlacemark = MKPlacemark(coordinate: trip.destinationCoordinates)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        mapManager.setCustomRegion(type: .destination, coordinates: trip.destinationCoordinates)
        if user.accountType == .passenger, self.pickupPlacemark != nil {
            mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates, title: "Pickup")
            generatePolyline(fromPickup: pickupMapItem, toDestination: destinationMapItem)
            mapView.zoomToTwoAnnotations(annotations: mapView.annotations)
        } else {
            generatePolyline(toDestination: destinationMapItem)
            mapView.zoomToFit(annotations: mapView.annotations)
        }
    }
    
    private func endTrip() {
        animateRideActionView(shouldShow: false)
        mapManager.removeAnnotationsAndOverlays()
        mapManager.removeDriverAnnotations()
        mapManager.showUserLocation()
        configureActionButton(config: .showMenu)
        showInputActivationView()
        fetchDrivers()
    }
    
    private func deleteTrip() {
        PassengerService.shared.deleteTrip { [weak self] _, _ in
            self?.animateRideActionView(shouldShow: false)
            self?.mapManager.removeAnnotationsAndOverlays()
            self?.mapManager.showUserLocation()
            self?.configureActionButton(config: .showMenu)
            self?.showInputActivationView()
            self?.fetchDrivers()
        }
    }
    
    private func fetchDrivers() {
        guard let location = locationManager.location else { return }
        
        PassengerService.shared.fetchDrivers(location: location) {[weak self] driver in
            guard let `self` = self else { return }
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(coordinate: coordinate, uid: driver.uid)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { [weak self] annotation in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        self?.mapManager.zoomForActiveTrip(driverUid: driver.uid)
                        return true
                    }
                    return false
                }
            }
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    //MARK: - Drivers API
    private func observeTrips() {
        DriverService.shared.observeTrip { [weak self] trip in
            self?.trip = trip
        }
    }
    
    private func observeCancelledTrip(trip: Trip) {
        DriverService.shared.observeTripCancelled(trip: trip) { [weak self] in
            self?.presentAlertController(withTitle: "Oops!", message: "The passenger decided to cancel this trip. Press OK to continue.")
            self?.animateRideActionView(shouldShow: false)
            self?.mapManager.removeAnnotationsAndOverlays()
            self?.mapManager.showUserLocation()
        }
    }
    
    //MARK: - Helper Functions
    private func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        view.addSubview(showUserLocationButton)
        showUserLocationButton.anchor(right: view.rightAnchor, bottom: view.bottomAnchor, paddingRight: 16, paddingBottom: rideActionViewHeight + 16, width: 30, height: 30)
    }
    
    private func configureActionButton(config: ActionButonConfiguration) {
        switch config {
        case .showMenu:
            actionButton.setImage(AppImages.menuIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .default), for: .normal)
            actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(AppImages.backIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .large), for: .normal)
            actionButtonConfig = .dismissActionView
        case .dissmissPickupLocationView:
            actionButton.setImage(AppImages.backIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .large), for: .normal)
            actionButtonConfig = .dissmissPickupLocationView
        }
    }
    
    private func configureInputActivationView() {
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        showInputActivationView()
    }
    
    private func showInputActivationView(shouldShow: Bool = true) {
        if shouldShow {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.inputActivationView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.inputActivationView.alpha = 0
            }
        }
    }
    
    private func configureLocationInputView() {
        locationInpitView.delegate = self
        locationInpitView.startingLocationTextField.myDelegate = self
        view.addSubview(locationInpitView)
        locationInpitView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInpitView.alpha = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.locationInpitView.alpha = 1
            self.tableView.frame.origin.y = self.locationInputViewHeight
        }
    }
    
    private func dismissLocationInputView(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.locationInpitView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { [weak self] _ in
            self?.locationInpitView.removeFromSuperview()
            self?.tableView.removeFromSuperview()
            
            guard let completion = completion else { return }
            completion()
        }
    }
    
    private func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    private func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil,
                                       config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.rideActionView.frame.origin.y = yOrigin
        }
        if shouldShow {
            guard let config = config else { return }
            if let destination = destination {
                rideActionView.destination = destination
            }
            if let user = user {
                rideActionView.user = user
            }
            rideActionView.config = config
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .mainWhiteTint
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.sectionHeaderTopPadding = 10
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
        configrureSavedUserLocations()
    }
    
    private func configrureSavedUserLocations() {
        guard let user = user else { return }
        savedLocations.removeAll()
        
        if let homeLocation = user.homeLocation {
            geocodeAddressString(address: homeLocation)
        }
        if let workLocation = user.workLocation {
            geocodeAddressString(address: workLocation)
        }
    }
    
    private func geocodeAddressString(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let clPlacemark = placemarks?.first else { return }
            let placemark = MKPlacemark(placemark: clPlacemark)
            self?.savedLocations.append(placemark)
            self?.tableView.reloadData()
        }
    }
    
    private func setupStartingLocationText(withPlacemark placemark: CLPlacemark?) -> String {
        var address = ""
        if let city = placemark?.locality { address.append(" \(city)") }
        if let street = placemark?.thoroughfare { address.append(", \(street)") }
        if let build = placemark?.subThoroughfare { address.append(", \(build)") }
        return address
    }
    
    private func showChangePickupLocationUI(shouldShow: Bool = true) {
        if shouldShow {
            pickupLocationView.delegate = self
            enableSetPickupCoordinates = true
            configureActionButton(config: .dissmissPickupLocationView)
            
            view.addSubview(pickupLocationView)
            pickupLocationView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
            
            view.addSubview(pinImage)
            pinImage.anchor(height: 50)
            pinImage.centerX(inView: view)
            pinImage.centerY(inView: view, constants: -15)
            
            
        } else {
            pickupLocationView.removeFromSuperview()
            pinImage.removeFromSuperview()
            enableSetPickupCoordinates = false
            presentLocationInputView()
            configureActionButton(config: .showMenu)
        }
    }
    
}

//MARK: - MapView Helper Functions
private extension HomeController {
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    func generatePolyline(fromPickup pickup: MKMapItem? = nil, toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = pickup == nil ? MKMapItem.forCurrentLocation() : pickup
        request.destination = destination
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { [weak self] responce, error in
            guard let responce = responce else { return }
            self?.route = responce.routes.first
            guard let polyline = self?.route?.polyline else { return }
            self?.mapView.addOverlay(polyline)
        }
    }
    
}

//MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = user, user.accountType == .driver else { return }
        guard let location = userLocation.location else { return }
        DriverService.shared.updateDriverLocation(location: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let driverAnnotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: driverAnnotation, reuseIdentifier: annotationIdentifier)
            view.image = AppImages.taxiIcon.unwrapImage
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .mainGreenTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard enableSetPickupCoordinates == true else { return }
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { [weak self] placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }
            self?.pickupPlacemark = placemark
        }
    }
    
}

//MARK: - CLLocationManagerDelegate
extension HomeController: CLLocationManagerDelegate {
    
    //    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    //        if region.identifier == AnnotationType.pickup.rawValue {
    //            print("DEBUG: Did start monitoring pickup region \(region)")
    //        }
    //        if region.identifier == AnnotationType.destination.rawValue {
    //            print("DEBUG: Did start monitoring destination region \(region)")
    //        }
    //    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { [weak self] err, ref in
                self?.rideActionView.config = .pickupPassenger
            }
        }
        if region.identifier == AnnotationType.destination.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .arriveAtDestination) { [weak self] err, ref in
                self?.rideActionView.config = .endTrip
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        LocationHandler.shared.checkLocationAuthorization(manager: manager) { [weak self] in
            self?.presentAlertController(withTitle: "Your location is not available", message: "To give permission go to: Settings -> CAB -> Location")
        }
    }
    
}

//MARK: - LocationInputActivationViewDelegate
extension HomeController: LocationInputActivationViewDelegate {
    
    func presentLocationInputView() {
        showInputActivationView(shouldShow: false)
        configureTableView()
        configureLocationInputView()
    }
    
}

//MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate {
    
    func dismissLocationInputView() {
        dismissLocationInputView { [weak self] in
            self?.showInputActivationView()
        }
    }
    
    func executeSearch(query: String) {
        mapManager.searchBy(naturalLanguageQuery: query) { [weak self] results in
            self?.searchResults = results
            self?.tableView.reloadData()
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedLocations.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved Locations" : "Results"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            var content = headerView.defaultContentConfiguration()
            content.text = section == 0 ? "Saved Locations" : "Results"
            content.textProperties.font = .boldSystemFont(ofSize: 16)
            content.textProperties.color = .darkGray
            headerView.contentConfiguration = content
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 0 {
            cell.placemark = savedLocations[indexPath.row]
        }
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var pickupCoordinatesIsChanged = false
        
        let selectedPlacemark = indexPath.section == 0 ? savedLocations[indexPath.row] : searchResults[indexPath.row]
        configureActionButton(config: .dismissActionView)
        
        let destinationMapItem = MKMapItem(placemark: selectedPlacemark)
        self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate, title: "Destination")
        
        if let changedPickupCoordinates = pickupPlacemark?.location?.coordinate {
            pickupCoordinatesIsChanged = true
            let pickupPlacemark = MKPlacemark(coordinate: changedPickupCoordinates)
            let pickupMapItem = MKMapItem(placemark: pickupPlacemark)
            mapView.addAnnotationAndSelect(forCoordinate: pickupPlacemark.coordinate, title: "Pickup")
            generatePolyline(fromPickup: pickupMapItem, toDestination: destinationMapItem)
        } else {
            generatePolyline(toDestination: destinationMapItem)
        }
        
        dismissLocationInputView { [weak self] in
            guard let `self` = self else { return }
            let annotations = self.mapView.annotations.filter { !($0.isKind(of: DriverAnnotation.self)) }
            
            pickupCoordinatesIsChanged ? self.mapView.zoomToTwoAnnotations(annotations: annotations) : self.mapView.zoomToFit(annotations: annotations)
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
        }
    }
}

//MARK: - RideActionViewDelegate
extension HomeController: RideActionViewDelegate {
    func uploadTrip(toDestination destination: MKPlacemark) {
        let destinationCoordinates = destination.coordinate
        let currentPickupCoordinates = locationManager.location?.coordinate
        let changedPickupCoordinates = pickupPlacemark?.location?.coordinate
        
        guard let pickupCoordinates = changedPickupCoordinates != nil ? changedPickupCoordinates : currentPickupCoordinates else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { [weak self] err, ref in
            if let error = err {
                print("DEBUG: Failed to upload trip with error \(error)")
                return
            }
            self?.animateRideActionView(shouldShow: false)
        }
    }
    
    func cancelTrip() {
        guard let user = user else { return }
        if user.accountType == .passenger {
            mapManager.removeDriverAnnotations()
            deleteTrip()
        } else {
            guard let trip = trip else { return }
            DriverService.shared.updateTripState(trip: trip, state: .danger) { [weak self] _, _ in
                self?.animateRideActionView(shouldShow: false)
                self?.mapManager.removeAnnotationsAndOverlays()
                self?.mapManager.showUserLocation()
                self?.configureActionButton(config: .showMenu)
            }
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func dropOffPassenger() {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip:  trip, state: .completed) { [weak self] _, _ in
            self?.animateRideActionView(shouldShow: false)
            self?.mapManager.removeAnnotationsAndOverlays()
            self?.mapManager.showUserLocation()
            self?.configureActionButton(config: .showMenu)
        }
    }
    
}

//MARK: - PickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates, title: "Pickup")
        self.mapManager.setCustomRegion(type: .pickup, coordinates: trip.pickupCoordinates)
        
        let pickupPlacemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let pickupMapItem = MKMapItem(placemark: pickupPlacemark)
        
        generatePolyline(toDestination: pickupMapItem)
        mapView.zoomToFit(annotations: mapView.annotations)
        
        observeCancelledTrip(trip: trip)
        
        dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid) { [weak self] passenger in
                self?.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
        }
    }
}


//MARK: - CustomTextFieldDelegate
extension HomeController: CustomTextFieldDelegate {
    func setCurrentLocation() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.locationInpitView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { [weak self] _ in
            self?.locationInpitView.removeFromSuperview()
            self?.tableView.removeFromSuperview()
            self?.showChangePickupLocationUI()
        }
    }
    
}

//MARK: - PickupLocationViewDelegate
extension HomeController: PickupLocationViewDelegate {
    func dismissPickupLocationView() {
        showChangePickupLocationUI(shouldShow: false)
    }
    
}
