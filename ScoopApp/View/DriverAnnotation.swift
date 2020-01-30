//
//  DriverAnnotation.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/29/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key:String
    
    init(coordinate:CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
    func updateAnnotationPosition(annotation:DriverAnnotation, coordinate:CLLocationCoordinate2D) {
        var location = self.coordinate
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        UIView.animate(withDuration: 0.2) {
//            DispatchQueue.main.async {
                self.coordinate = location
//            }
        }
    }
    
}

