//
//  HomeController.swift
//  UberTutorial
//
//  Created by Dmytro Grytsenko on 22.01.2023.
//

import UIKit
import FirebaseAuth
import MapKit

class HomeController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let inputActivationView = LocationInputActivationView()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chechIfUserIsLoggedIn()
        //                signOut()
        enableLocationServices()
    }
    
    //MARK: - API
    private func chechIfUserIsLoggedIn() {
        
        if Auth.auth().currentUser?.uid == nil {
            //            print("Debug: User not logged in")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true)
            }
            return
        } else {
            configureUI()
            //        print("User is logged in")
            //        print("User id is \(uid)")
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    //MARK: - Helper Functions
    func configureUI() {
        configureMapView()
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
}

//MARK: - Location Services

extension HomeController: CLLocationManagerDelegate {
    
    private func enableLocationServices() {
        
        locationManager.delegate = self
        
        switch CLLocationManager().authorizationStatus {
            
        case .notDetermined:
            print("DEBUG: Not deterined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}

