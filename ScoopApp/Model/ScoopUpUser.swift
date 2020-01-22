//
//  ScoopUpUser.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/14/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import Firebase

struct ScoopUpUser {
    
    var userType:String
    var uId:String
    var isPickUpModeEnabled:Bool
    var profileImageUrl:String
    var userName:String
    var email:String
    
    init() {
        self.userType = ""
        self.uId = ""
        self.isPickUpModeEnabled = false
        self.profileImageUrl = ""
        self.userName = ""
        self.email = ""
    }
    
    static func observePassengersAndDriver(uId:String, completion:@escaping(_ user:ScoopUpUser?,_ succeed:Bool) -> ()) {
    
            Database.database().reference().child("Passenger").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if snap.key == Auth.auth().currentUser?.uid {
                            var passenger = ScoopUpUser()
                            passenger.uId = uId
                            passenger.userType = "Passenger"
                            passenger.userName = snap.childSnapshot(forPath: "username").value as! String
                            passenger.email = snap.childSnapshot(forPath: "email").value as! String
                            passenger.isPickUpModeEnabled = snap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
                            passenger.profileImageUrl = snap.childSnapshot(forPath: "profileImageUrl").value as! String
                            completion(passenger, true)
                        }
                    }
                } else {
                    completion(nil, false)
                }
            }, withCancel: nil)
        
        Database.database().reference().child("Driver").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        var driver = ScoopUpUser()
                        driver.uId = uId
                        driver.userType = "Driver"
                        driver.userName = snap.childSnapshot(forPath: "username").value as! String
                        driver.email = snap.childSnapshot(forPath: "email").value as! String
                        driver.isPickUpModeEnabled = snap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
                        driver.profileImageUrl = snap.childSnapshot(forPath: "profileImageUrl").value as! String
                        completion(driver, true)
                    }
                }
            } else {
                completion(nil, false)
            }
        }, withCancel: nil)
    }
    
    
    static func togglePickUpMode(uid:String, toggle:UISwitch) {
        toggle.isOn ? Database.database().reference().child("Driver").child(uid).updateChildValues(["isPickUpModeEnabled": true]) : Database.database().reference().child("Driver").child(uid).updateChildValues(["isPickUpModeEnabled": false])
        
    }
    
}
