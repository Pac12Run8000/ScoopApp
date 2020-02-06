//
//  PassengerAnnotation.swift
//  ScoopApp
//
//  Created by Michelle Grover on 2/6/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import MapKit

class PassengerAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key:String
    
    init(coordinate:CLLocationCoordinate2D, key:String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
}
