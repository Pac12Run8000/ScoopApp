//
//  ViewController.swift
//  ScoopApp
//
//  Created by Michelle Grover on 12/29/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    let gradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        mapView.delegate = self
       
    }


}


extension ViewController:MKMapViewDelegate {
    
}

