//
//  MKMapView+Extensions.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 18.02.2023.
//

import MapKit

extension MKMapView {
    
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        annotations.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        let insets = UIEdgeInsets(top: 75, left: 75, bottom: 300, right: 75)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    func addAnnotationAndSelect(forCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        addAnnotation(annotation)
        selectAnnotation(annotation, animated: true)
    }

}
