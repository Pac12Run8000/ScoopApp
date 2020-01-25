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
}
