//
//  ViewController.swift
//  ScoopApp
//
//  Created by Michelle Grover on 12/29/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView

class ViewController: UIViewController {
    
    
    @IBOutlet weak var actionButtonOutlet: RoundedShadowButton!
    @IBOutlet weak var mapView: MKMapView!
    
//    let gradient = CAGradientLayer()
    
    
    var delegate:CenterVCDelegate?
    
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: .white)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupAndStartSplashAnimation()
       
       
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
// MARK:- Setting up the splashView functionality
extension ViewController {
    
    func setupAndStartSplashAnimation() {
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
    }
    
}



