//
//  HomeController.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 22.01.2023.
//

import UIKit
import FirebaseAuth
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

private enum ActionButonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

private enum AnnotationType: String {
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
    private var inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInpitView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var savedLocations = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    
    private var route: MKRoute?
    
    weak var delegate: HomeControllerDelegate?
    
    var user: User? {
        didSet {
            locationInpitView.user = user
            if user?.accountType == .passenger {
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
            guard let user = user else { return }
            if user.accountType == .driver {
                guard let trip = trip, trip.state == .requested else { return }
                let controller = PickupController(trip: trip)
                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            } else {
                print("DEBUG: Show ride action view for accepted trip...")
            }
        }
    }
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AppImages.menuIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .default), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private var actionButtonConfig = ActionButonConfiguration()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        enableLocationServices()
    }
    
    //MARK: - Selectors
    @objc private func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            delegate?.handleMenuToggle()
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    //MARK: - Passenger API
    private func observeCurentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let state = trip.state else { return }
            guard let driverUid = trip.driverUid else { return }
            switch state {
            case .requested:
                break
            case .denied:
                self.shouldPresentLoadingView(false)
                self.presentAlertController(withTitle: "Oops!", message: "It looks like we couldnt find you a driver. Please try again.")
                PassengerService.shared.deleteTrip { err, fef in
                    print("DEBUG: DELETE TRIP")
                    self.removeAnnotationsAndOverlays()
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    UIView.animate(withDuration: 0.5) {
                        self.inputActivationView.alpha = 1
                    }
                }
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationsAndOverlays()
                self.zoomForActiveTrip(withDriverUid: driverUid)
                
                Service.shared.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .danger:
                PassengerService.shared.deleteTrip { err, ref in
                    self.animateRideActionView(shouldShow: false)
                    self.removeAnnotationsAndOverlays()
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    UIView.animate(withDuration: 0.5) {
                        self.inputActivationView.alpha = 1
                    }
                    self.presentAlertController(withTitle: "Trip Completed", message: "You are behaving inappropriately.")
                }
                
            case .arriveAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                PassengerService.shared.deleteTrip { err, ref in
                    self.animateRideActionView(shouldShow: false)
                    self.removeAnnotationsAndOverlays()
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    UIView.animate(withDuration: 0.5) {
                        self.inputActivationView.alpha = 1
                    }
                    self.presentAlertController(withTitle: "Trip Completed", message: "We hope your enjoyed your trip")
                }
            }
        }
    }
    
    private func startTrip() {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { err, ref in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinates)
            
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
            self.generatePolyline(toDestination: mapItem)
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
            
        }
    }
    
    private func fetchDrivers() {
        guard let location = self.locationManager?.location else { return }
        //            print("DEBUG: Location is \(location)")
        PassengerService.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            //                print("DEBUG: Driver coorditate is \(coordinate)")
            let annotation = DriverAnnotation(coordinate: coordinate, uid: driver.uid)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { annotation in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        //                            print("DEBUG: Handle update driver position")
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
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
        DriverService.shared.observeTrip { trip in
            self.trip = trip
        }
    }
    
    private func observeCancelledTrip(trip: Trip) {
        DriverService.shared.observeTripCancelled(trip: trip) {
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverlays()
            self.centerMapOnUserLocation()
            self.presentAlertController(withTitle: "Oops! ", message: "The passenger has decided to cancel this trip. Press OK to continue.")
        }
    }
    
    //MARK: - Helper Functions
    private func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
    }
    
    private func configureActionButton(config: ActionButonConfiguration) {
        switch config {
        case .showMenu:
            actionButton.setImage(AppImages.menuIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .default), for: .normal)
            actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(AppImages.backIcon.unwrapImage.editedImage(tintColor: .backgroundColor, scale: .large), for: .normal)
            actionButtonConfig = .dismissActionView
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
                guard let `self` = self else { return }
                self.inputActivationView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let `self` = self else { return }
                self.inputActivationView.alpha = 0
            }
        }
    }
    
    private func configureLocationInputView() {
        locationInpitView.delegate = self
        view.addSubview(locationInpitView)
        locationInpitView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInpitView.alpha = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.locationInpitView.alpha = 1
            self.tableView.frame.origin.y = self.locationInputViewHeight
        }
    }
    
    private func dissmissLocationInputView(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let `self` = self else { return }
            self.locationInpitView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { [weak self] _ in
            guard let `self` = self else { return }
            self.locationInpitView.removeFromSuperview()
            self.tableView.removeFromSuperview()
            
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
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            self.rideActionView.frame.origin.y = yOrigin
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
            guard let `self` = self else { return }
            guard let clPlacemark = placemarks?.first else { return }
            let placemark = MKPlacemark(placemark: clPlacemark)
            self.savedLocations.append(placemark)
            self.tableView.reloadData()
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
    }
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping ([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { responce, error in
            guard let responce = responce else { return }
            responce.mapItems.forEach { item in
                results.append(item.placemark)
            }
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { responce, error in
            guard let responce = responce else { return }
            self.route = responce.routes.first
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        
        mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.overlays.forEach { overlay in
                mapView.removeOverlay(overlay)
            }
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withType type: AnnotationType, coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
    }
    
    func zoomForActiveTrip(withDriverUid uid: String) {
        var annotations = [MKAnnotation]()
        self.mapView.annotations.forEach { annotation in
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == uid {
                    annotations.append(anno)
                }
            }
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        self.mapView.zoomToFit(annotations: annotations)
    }
    
    func zoomForActiveDrivers(withAnnotation annotation: MKAnnotation) {
        var annotations = [MKAnnotation]()
        self.mapView.annotations.forEach { annotation in
            if let anno = annotation as? DriverAnnotation {
                annotations.append(anno)
            }
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        self.mapView.zoomToFit(annotations: annotations)
    }
    
}

//MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = user else { return }
        guard user.accountType == .driver else { return }
        guard let location = userLocation.location else { return }
        DriverService.shared.updateDriverLocation(location: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
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
    
}

//MARK: - CLLocationManagerDelegate
extension HomeController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pickup region \(region)")
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region \(region)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Driver did enter to pickup region \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { err, ref in
                self.rideActionView.config = .pickupPassenger
            }
        }
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Driver did enter to destination region \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .arriveAtDestination) { err, ref in
                self.rideActionView.config = .endTrip
            }
        }
        
        
    }
    
    private func enableLocationServices() {
        locationManager?.delegate = self
        switch CLLocationManager().authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not deterined")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
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
        dissmissLocationInputView { [weak self] in
            guard let `self` = self else { return }
            self.showInputActivationView()
        }
    }
    
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { results in
            //            print("DEBUG: Placemark is \(results) ")
            self.searchResults = results
            self.tableView.reloadData()
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
        
        let selectedPlacemark = indexPath.section == 0 ? savedLocations[indexPath.row] : searchResults[indexPath.row]
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dissmissLocationInputView { [weak self] in
            guard let `self` = self else { return }
            self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate)
            
            let annotations = self.mapView.annotations.filter { !($0.isKind(of: DriverAnnotation.self)) }
            //            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            //            print("DEBUG: Annotation is \(annotations)")
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
        }
    }
}

//MARK: - RideActionViewDelegate
extension HomeController: RideActionViewDelegate {
    
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { err, ref in
            if let error = err {
                print("DEBUG: Failed to upload trip with error \(error)")
                return
            }
            //            print("DEBUG: Did uploar trip successfully")
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
    func cancelTrip() {
        if user?.accountType == .passenger {
            PassengerService.shared.deleteTrip { error, ref in
                if let error = error {
                    print("DEBUG: Error deleting trip \(error.localizedDescription)")
                    return
                }
                self.animateRideActionView(shouldShow: false)
                self.removeAnnotationsAndOverlays()
                self.centerMapOnUserLocation()
                self.configureActionButton(config: .showMenu)
                
                UIView.animate(withDuration: 0.5) {
                    self.inputActivationView.alpha = 1
                }
            }
        } else {
            guard let trip = trip else { return }
            DriverService.shared.updateTripState(trip: trip, state: .danger) { err, ref in
                if let error = err {
                    print("DEBUG: Error deleting trip \(error.localizedDescription)")
                    return
                }
                self.animateRideActionView(shouldShow: false)
                self.removeAnnotationsAndOverlays()
                self.centerMapOnUserLocation()
                self.configureActionButton(config: .showMenu)
                
                UIView.animate(withDuration: 0.5) {
                    self.inputActivationView.alpha = 1
                }
            }
        }
        
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func dropOffPassenger() {
        guard let trip = trip else { return }
        DriverService.shared.updateTripState(trip:  trip, state: .completed) { err, ref in
            self.removeAnnotationsAndOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
        }
    }
    
}

//MARK: - PickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        
        generatePolyline(toDestination: mapItem)
        mapView.zoomToFit(annotations: mapView.annotations)
        
        observeCancelledTrip(trip: trip)
        
        dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid) { passenger in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
                self.setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
            }
        }
    }
}
