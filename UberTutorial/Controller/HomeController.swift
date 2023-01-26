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

class HomeController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInpitView = LocationInputView()
    private let tableView = UITableView()
    private var user: User? {
        didSet { locationInpitView.user = user }
    }
    
    private final let locationInputViewHeight: CGFloat = 200
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chechIfUserIsLoggedIn()
        enableLocationServices()
        
        //        signOut()
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
    func configure() {
        configureUI()
        fetchUserData()
        fetchDrivers()
    }
    
    func configureUI() {
        configureMapView()
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        configureTableView()
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
        UIView.animate(withDuration: 0.3) {
            self.locationInpitView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInpitView.removeFromSuperview()
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
            }
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
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
        
        return cell
    }
    
}
