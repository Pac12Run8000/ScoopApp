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
    
    
    @IBOutlet weak var actionButtonOutlet: RoundedShadowButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let gradient = CAGradientLayer()
    
    var delegate:CenterVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        mapView.delegate = self
       
    }

    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionButtonOutlet.animateButton(shouldLoad: true, with: nil)
        
    }
    
    @IBAction func menuButtonPressedAction(_ sender: Any) {
       
        delegate?.toggleLeftPanel()
        
    }
    
    
}


extension ViewController:MKMapViewDelegate {
    
}



