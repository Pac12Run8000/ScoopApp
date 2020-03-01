//
//  UpdateService.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/24/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class UpdateService {
    
    static var instance = UpdateService()
    
    
    func updatePassengerLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
       guard let uid = Auth.auth().currentUser?.uid else {
           print("This passenger doesn't have a uid.")
           return
       }
        
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == uid { DataService.instance.REF_USERS.child(user.key).updateChildValues(["coordinate":[coordinate.latitude, coordinate.longitude]])
                    }
                }
            }
        }
        
        
        
        
    }
    
    func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("This driver doesn't have a uid.")
            return
        }
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
                    if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
        
                        
                        for driver in driverSnapshot {
                            if driver.key == uid {
                               
                                if driver.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool == true {
                                    DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues(["coordinate":[coordinate.latitude, coordinate.longitude]])
                                }
                            }
                        }
                    }
                }
        
        
    }
    
    
    func updateTripsWithCoordinatesUponRequest() {
        
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        if let userDict = user.value as? Dictionary<String, AnyObject> {
                            let pickUpArray = userDict["coordinate"] as! NSArray
                            let destinationArray = userDict["tripCoordinate"] as! NSArray
                            DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["pickUpCoordinate":[pickUpArray[0], pickUpArray[1]], "destinationCoordinate": [destinationArray[0], destinationArray[1]], "passengerKey":user.key, "tripAccepted":false])
                        }
                        
                    }
                }
                
            }
        })

    }
    
    func observeTrips(handler:@escaping(_ coordinateDict:Dictionary<String, AnyObject>?) -> ()) {
        
        DataService.instance.REF_TRIPS.observe(.value, with: { (snapshot) in
            if let tripSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for trip in tripSnapshot {
                    if trip.hasChild("passengerKey") && trip.hasChild("tripAccepted") {
                        if let tripDict = trip.value as? Dictionary<String, AnyObject> {
                            handler(tripDict)
                        }
                    }
                }
            }
        })
        
    }
    
    func acceptTrip(passengerKey:String, driverKey:String) {
        DataService.instance.REF_TRIPS.child(passengerKey).updateChildValues(["driverKey":driverKey,"tripAccepted":true])
            DataService.instance.REF_DRIVERS.child(driverKey).updateChildValues(["driverIsOnTrip":true])
        
    }
    
    func cancelTrip(passengerKey:String, driverKey:String) {
        DataService.instance.REF_TRIPS.child(passengerKey).removeValue()
        DataService.instance.REF_USERS.child(passengerKey).child("tripCoordinate").removeValue()
        DataService.instance.REF_DRIVERS.child(driverKey).updateChildValues(["driverIsOnTrip":false])
    }
    
}
