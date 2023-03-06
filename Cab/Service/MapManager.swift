//
//  MapManager.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 26.02.2023.
//

import MapKit

class MapManager {
    
    let mapView: MKMapView
    let locationManager = LocationHandler.shared.locationManager
    private let regionInMetters = 2_000.00
    
    init(mapView: MKMapView) {
        self.mapView = mapView
    }
    
    func showUserLocation(completion: (() -> Void)? = nil) {
        guard let coordinate = locationManager.location?.coordinate else {
            guard let completion = completion else { return }
            completion()
            return
        }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionInMetters, longitudinalMeters: regionInMetters)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(type: AnnotationType, coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: type.rawValue)
        locationManager.startMonitoring(for: region)
    }
    
    
    func zoomForActiveTrip(driverUid uid: String) {
        var annotations = [MKAnnotation]()
        
        mapView.annotations.forEach { annotation in
            if let driverAnnotation = annotation as? DriverAnnotation {
                driverAnnotation.uid == uid ? annotations.append(driverAnnotation) : mapView.removeAnnotation(driverAnnotation)
            }
            if let userAnnotation = annotation as? MKUserLocation {
                annotations.append(userAnnotation)
            }
        }
        mapView.zoomToFit(annotations: annotations)
    }
    
    func removeAnnotationsAndOverlays() {
        
        mapView.annotations.forEach { annotation in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        
        mapView.removeOverlays(mapView.overlays)
        //        if mapView.overlays.count > 0 {
        //            mapView.overlays.forEach { overlay in
        //                mapView.removeOverlay(overlay)
        //            }
        //        }
    }
    
    func removeDriverAnnotations() {
        mapView.annotations.forEach { annotation in
            if let driverAnnotation = annotation as? DriverAnnotation {
                mapView.removeAnnotation(driverAnnotation)
            }
        }
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
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}
