//
//  DriverAnnotation.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 26.01.2023.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(coordinate: CLLocationCoordinate2D, uid: String) {
        self.coordinate = coordinate
        self.uid = uid
    }
    
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let `self` = self else { return }
            self.coordinate = coordinate
        }
    }
    
}
