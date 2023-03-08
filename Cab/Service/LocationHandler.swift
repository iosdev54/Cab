// 
//  LocationHandler.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 25.01.2023.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    //MARK: - Priperties
    static let shared = LocationHandler()
    let locationManager = CLLocationManager()
    
    //MARK: - Lifecycle
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    //MARK: - Helper Functions
    func checkLocationAuthorization(manager: CLLocationManager, completion: () -> Void) {
        
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
}

