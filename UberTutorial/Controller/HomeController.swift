//
//  HomeController.swift
//  UberTutorial
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

class HomeController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private var inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInpitView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    
    private var route: MKRoute?
    
    private var user: User? {
        didSet {
            locationInpitView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureInputActivationView()
            }
        }
    }
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    private var actionButtonConfig = ActionButonConfiguration()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chechIfUserIsLoggedIn()
        enableLocationServices()
        
                signOut()
    }
    
    //MARK: - Selectors
    @objc private func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("Handle show menu...")
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
    
    //MARK: - API
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    private func fetchDrivers() {
        DispatchQueue.main.async {
            guard let location = self.locationManager?.location else { return }
            //            print("DEBUG: Location is \(location)")
            Service.shared.fechhDrivers(location: location) { driver in
                guard let coordinate = driver.location?.coordinate else { return }
                //                print("DEBUG: Driver coorditate is \(coordinate)")
                let annotation = DriverAnnotation(coordinate: coordinate, uid: driver.uid)
                
                var driverIsVisible: Bool {
                    return self.mapView.annotations.contains { annotation in
                        guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                        if driverAnnotation.uid == driver.uid {
                            //                            print("DEBUG: Handle update driver position")
                            driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
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
        
    }
    
    private func chechIfUserIsLoggedIn() {
        
        if Auth.auth().currentUser?.uid == nil {
            //            print("Debug: User not logged in")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true)
            }
            return
        } else {
            configure()
            //        print("User is logged in")
            //        print("User id is \(uid)")
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true)
            }
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    //MARK: - Helper Functions
    private func configureActionButton(config: ActionButonConfiguration) {
        switch config {
        case .showMenu:
            actionButton.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(UIImage(named: "baseline_arrow_back_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    func configure() {
        configureUI()
        fetchUserData()
    }
    
    private func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30, height: 30)

        configureTableView()
    }
    
    private func configureInputActivationView() {
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    private func configureLocationInputView() {
        locationInpitView.delegate = self
        view.addSubview(locationInpitView)
        locationInpitView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInpitView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.locationInpitView.alpha = 1
        } completion: { _ in
            //            print("DEBUG: Present table view")
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    private func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        //        tableView.sectionHeaderTopPadding = 0
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    private func dissmissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInpitView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInpitView.removeFromSuperview()
        }, completion: completion)
    }
    
    private func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        if shouldShow {
            guard let destination = destination else { return }
            rideActionView.destination = destination
        }
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
    }
    
}

//MARK: - MapView Helper Functions
private extension HomeController {
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
}

//MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    
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
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
}

//MARK: - Location Services
extension HomeController {
    
    private func enableLocationServices() {
        
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
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
}

//MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate {
    
    func dismissLocationInputView() {
        dissmissLocationView { _ in
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
            }
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
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let headerView = UIView()
    //        headerView.backgroundColor = .systemGroupedBackground
    //        let headerTitle = UILabel()
    //        headerTitle.text = "Test"
    //        headerTitle.font = UIFont.boldSystemFont(ofSize: 14)
    //        headerTitle.textAlignment = .left
    //        headerView.addSubview(headerTitle)
    //        headerTitle.centerY(inView: headerView, leftAnchor: headerView.leftAnchor, paddingLeft: 20, rightAnchor: headerView.rightAnchor, paddingRight: 20)
    //        return headerView
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = self.searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dissmissLocationView { _ in
            //            print("DEBUG: Add annotation here..")
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            annotation.title = selectedPlacemark.name
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            let annotations = self.mapView.annotations.filter { !($0.isKind(of: DriverAnnotation.self)) }
            //            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            //            print("DEBUG: Annotation is \(annotations)")
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark)
        }
    }
}

//MARK: - RideActionViewDelegate
extension HomeController: RideActionViewDelegate {
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { err, feff in
            if let error = err {
                print("DEBUG: Failed to upload trip with error \(error)")
                return
            }
            print("DEBUG: Did uploar trip successfully")
        }
    }

}
