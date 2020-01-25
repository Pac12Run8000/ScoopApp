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
import CoreLocation
import Firebase

class ViewController: UIViewController {
    
    
    @IBOutlet weak var actionButtonOutlet: RoundedShadowButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate:CenterVCDelegate?
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: .white)

    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationServices()
        setupAndStartSplashAnimation()
        mapView.delegate = self
       
    }
    


    @IBAction func actionButtonWasPressed(_ sender: Any) {
        actionButtonOutlet.animateButton(shouldLoad: true, with: nil)
        
    }
    
    @IBAction func menuButtonPressedAction(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    @IBAction func centerButtonAction(_ sender: Any) {
        
        if let location = locationManager.location?.coordinate {
            let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
        
        
    }
    
}

// MARK:- This is where the locationmanger functionality is located
extension ViewController: CLLocationManagerDelegate {
    
    
    
    func checkLocationServices() {
        
        if (CLLocationManager.locationServicesEnabled()) {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            print("Location services aren't enabled.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {

            let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Show alert letting kids know that they are not allowed to access the location.")
        }
    }
    

   
    
    
}
// MARK:- Mapview delegate functionality
extension ViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No uid.")
            return
        }
        
        ScoopUpUser.observePassengersAndDriver(uId: uid) { (user, didSucceed) in
            if !didSucceed {
                print("No user.")
                return
            }
            
            
            switch user?.userType {
            case "Driver":
                print("This is a driver")
                UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
                break
            case "Passenger":
                print("This is a passenger")
                UpdateService.instance.updatePassengerLocation(withCoordinate: userLocation.coordinate)
                break
            default:
                break
            }
        }
        
//        UpdateService.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
//        UpdateService.instance.updatePassengerLocation(withCoordinate: userLocation.coordinate)
        
        
        
    }
    
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



