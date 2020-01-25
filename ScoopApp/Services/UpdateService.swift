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
                                    print("Driver:\(driver.key)")
                                    DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues(["coordinate":[coordinate.latitude, coordinate.longitude]])
                                }
                            }
                        }
                    }
                }
        
        
    }
    
    
    
//    func updatePassengerLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("This passenger doesn't have a uid.")
//            return
//        }
//
//        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
//            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for user in userSnapshot {
//                    if user.key == uid {
//                        print("Passenger:", user.key)
////                        DataService.instance.REF_USERS.child(user.key).updateChildValues(["coordinate":[coordinate.latitude, coordinate.longitude]])
//                    }
//                }
//            }
//        }
//    }
//
//    func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("This driver doesn't have a uid.")
//            return
//        }
//
//        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
//            if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
//
//                for driver in driverSnapshot {
//                    print("Driver:", driver.key)
//                }
////                for driver in driverSnapshot {
//////                    if driver.key == uid, driver.childSnapshot(forPath: "isPickUpModeEnabled") as? Bool == true {
//////                        DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues(["coordinate":[coordinate.latitude, coordinate.longitude]])
//////                    }
////                }
//            }
//        }
//    }
    
}
