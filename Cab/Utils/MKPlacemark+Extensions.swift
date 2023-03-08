//
//  MKPlacemark+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 18.02.2023.
//

import MapKit

extension MKPlacemark {
    
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else { return nil}
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil }
            guard let administrativeArea = administrativeArea else { return nil }
            
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea)"
        }
    }
    
}
