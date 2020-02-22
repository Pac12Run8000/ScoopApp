//
//  DataService.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/9/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import Firebase


let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("Passenger")
    private var _REF_DRIVERS = DB_BASE.child("Driver")
    private var _REF_TRIPS = DB_BASE.child("Trips")
    
    var REF_BASE:DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS:DatabaseReference {
        return _REF_USERS
    }
    
    var REF_DRIVERS:DatabaseReference {
        return _REF_DRIVERS
    }
    
    var REF_TRIPS:DatabaseReference {
        return _REF_TRIPS
    }
    
    func createFirebaseDBUser(uid:String, userData:[String:Any], isDriver:Bool) {
        if isDriver {
            REF_DRIVERS.child(uid).updateChildValues(userData)
        } else {
            REF_USERS.child(uid).updateChildValues(userData)
        }
    }
    
    func driverIsAvailable(key:String, handler:@escaping(_ status:Bool?) -> ()) {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapShot) in
            if let driverSnapShot = snapShot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapShot {
                    if driver.key == key {
                        if driver.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool == true {
                            if driver.childSnapshot(forPath: "driverIsOnTrip").value as? Bool == true {
                                handler(false)
                            } else {
                                handler(true)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func driverIsOnTrip(key:String, handler:@escaping(_ status:Bool?,_ driverkey:String?,_ tripKey:String?) -> ()) {
        DataService.instance.REF_DRIVERS.child(key).child("driverIsOnTrip").observe(.value, with: { (driverTripStatusSnapshot) in
            
            if let driverTripStatusSnapshot = driverTripStatusSnapshot.value as? Bool, driverTripStatusSnapshot == true {
                DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with:  { (tripSnapshot) in
                    if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                        for trip in tripSnapshot {
                            if trip.childSnapshot(forPath: "driverKey").value as? String == key {
                                handler(true, key, trip.key)
                            } else {
                                return
                            }
                        }
                    }
                })
            } else {
                handler(false, nil, nil)
            }
            
        })
    }
    
    func userIsOnTrip(passengerKey:String, handler:@escaping(_ status:Bool?, _ driverKey:String?, _ tripKey:String?) -> ()) {
        
        DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
            if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                for trip in tripSnapshot {
                    if trip.key == passengerKey {
                        if trip.childSnapshot(forPath: "tripAccepted").value as? Bool == true {
                            let driverKey = trip.childSnapshot(forPath: "driverKey").value as? String
                            handler(true, driverKey, trip.key)
                        } else {
                            handler(false, nil, nil)
                        }
                        
                    }
                }
//                for trip in tripSnapshot {
//                    if trip.key == passengerKey {
//
//                        if trip.childSnapshot(forPath: "tripAccepted").value as? Bool == true {
//                            let driverKey = trip.childSnapshot(forPath: "driverKey") as? String
//                            handler(true, driverKey, trip.key)
//                        }
//
//                    } else {
//                        handler(false, nil, nil)
//                    }
//                }
            }
        })
        
    }
    
}
