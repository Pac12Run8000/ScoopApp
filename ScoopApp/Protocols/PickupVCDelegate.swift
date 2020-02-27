//
//  PickupVCDelegate.swift
//  ScoopApp
//
//  Created by Michelle Grover on 2/25/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

protocol PickupVCDelegate:class {
    func pickupViewController(controller:PickUpVC, itemForPolyline item:MKMapItem?)
}
