//
//  PickUpVC.swift
//  ScoopApp
//
//  Created by Michelle Grover on 2/12/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class PickUpVC: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    weak var pickupVCDelegate:PickupVCDelegate?
    
    var regionRadius:CLLocationDistance = 2000
    var pin:MKPlacemark? = nil
    var pickupCoordinate:CLLocationCoordinate2D!
    var passengerKey:String!
    var locationPlaceMark:MKPlacemark!
    var currentUserId = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        setHeightForMapview()
        mapView.delegate = self
        locationPlaceMark = MKPlacemark(coordinate: pickupCoordinate)
        dropPinForPlaceMark(placeMark: locationPlaceMark)
        centerMapOnLocation(location: locationPlaceMark.location!)
        
        DataService.instance.REF_TRIPS.child(passengerKey).observe(.value, with: { (tripSnapshot) in
            if tripSnapshot.exists() {
                if tripSnapshot.childSnapshot(forPath: "tripAccepted").value as? Bool == true {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        

       
    }
    
    @IBAction func cancelButtonActionPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptTripButtonPressed(_ sender: Any) {
        UpdateService.instance.acceptTrip(passengerKey: passengerKey, driverKey: currentUserId!)
        
        guard let pickupCoordinate = pickupCoordinate, let pickUpPlaceMark = MKPlacemark(coordinate: pickupCoordinate) as? MKPlacemark, let mapItem = MKMapItem(placemark: pickUpPlaceMark) as? MKMapItem  else {
            print("There is no pickup coordinate.")
            return
        }
        
        pickupVCDelegate?.pickupViewController(controller: self, itemForPolyline: mapItem)
        
//        let delegate = AppDelegate.getAppDelegate()
//        delegate.window?.rootViewController?.shouldPresentLoadingView(status: true)
    }
    
    func initData(coordinate:CLLocationCoordinate2D, passengerKey:String) {
        self.pickupCoordinate = coordinate
        self.passengerKey = passengerKey
    }
    

}

// MARK:- MapViewDelegate functionality
extension PickUpVC:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var identifier = "pickUpPoint"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation:annotation as! MKAnnotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "destinationAnnotation")
        return annotationView
    }
    
    func centerMapOnLocation(location:CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func dropPinForPlaceMark(placeMark:MKPlacemark) {
        pin = placeMark
        
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = placeMark.coordinate
        mapView.addAnnotation(annotation)
    }
    
}

// MARK:- This sets the height equal to the width so that the mapView can be a perfect circle
extension PickUpVC {
    
    func setHeightForMapview() {
         mapViewHeightConstraint.constant = mapView.frame.width
    }
    
}


