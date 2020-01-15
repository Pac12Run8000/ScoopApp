//
//  LeftSidePanelVC.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/1/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import Firebase

class LeftSidePanelVC: UIViewController {

    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var accountTypeLabelOutlet: UILabel!
    @IBOutlet weak var profileImageViewOutlet: RoundImageView!
    @IBOutlet weak var loginLogoutButtonOutlet: UIButton!
    @IBOutlet weak var pickUpSwitchOutlet: UISwitch!
    @IBOutlet weak var pickupModeLabelOutlet: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser == nil {
            loginLogoutButtonOutlet.setTitle("Sign Up / Login", for: .normal)
        } else {
            loginLogoutButtonOutlet.setTitle("Log Out", for: .normal)
        }
        
//        pickUpSwitchOutlet.isOn = false
//        pickUpSwitchOutlet.isHidden = true
//        pickupModeLabelOutlet.isHidden = true
        
//        observePassengersAndDriver()
        
//        if Auth.auth().currentUser == nil {
//            emailLabelOutlet.text = ""
//            accountTypeLabelOutlet.text = ""
//            profileImageViewOutlet.isHidden = true
//            pickupModeLabelOutlet.isHidden = true
//            pickUpSwitchOutlet.isHidden = true
//            loginLogoutButtonOutlet.setTitle("Sign Up / Login", for: .normal)
//        } else {
//            emailLabelOutlet.text = Auth.auth().currentUser?.email
//            accountTypeLabelOutlet.text = ""
//            profileImageViewOutlet.isHidden = false
//            loginLogoutButtonOutlet.setTitle("Log Out", for: .normal)
//        }
    }
    
//    func observePassengersAndDriver() {
//
//        Database.database().reference().child("Passenger").observeSingleEvent(of: .value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    if snap.key == Auth.auth().currentUser?.uid {
//                        self.accountTypeLabelOutlet.text = "Passenger"
//                    }
//                }
//            }
//        }, withCancel: nil)
//
//        Database.database().reference().child("Driver").observeSingleEvent(of: .value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    if snap.key == Auth.auth().currentUser?.uid {
//                        self.accountTypeLabelOutlet.text = "Driver"
//                        self.pickUpSwitchOutlet.isHidden = false
//                        let switchStatus = snap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
//                        self.pickUpSwitchOutlet.isOn = switchStatus
//                        self.pickupModeLabelOutlet.isHidden = false
//                    }
//                }
//            }
//        }, withCancel: nil)
        
        
        
//    }
    
    @IBAction func signUpLoginBtnActionPressed(_ sender: Any) {
        
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "loginVCSegue", sender: self)
        } else {
            logout { (succeed) in
                if succeed! {
                    print("Logged Out.")
                    self.emailLabelOutlet.text = ""
                    self.accountTypeLabelOutlet.text = ""
                    self.profileImageViewOutlet.isHidden = true
                    self.pickupModeLabelOutlet.isHidden = true
                    self.pickUpSwitchOutlet.isHidden = true
                }
            }
        }
        
//        if Auth.auth().currentUser == nil {
//            performSegue(withIdentifier: "loginVCSegue", sender: self)
//        } else {
//            logout { (success) in
//                if success! {
//                    print("Signed out.")
//                    self.emailLabelOutlet.text = ""
//                    self.accountTypeLabelOutlet.text = ""
//                    self.profileImageViewOutlet.isHidden = true
//                    self.pickupModeLabelOutlet.isHidden = true
//                    self.pickUpSwitchOutlet.isHidden = true
//                    self.loginLogoutButtonOutlet.setTitle("Sign Up / Login", for: .normal)
//
//                }
//            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loginVCSegue") {
            let controller = segue.destination as? LoginVC
            controller?.loginDelegate = self
            
        }
    }
    
    

}


// MARK:- Delegate / Protocol functionality
extension LeftSidePanelVC:LoginDelegate {
    
    func setUserProfile(scoopUser: ScoopUpUser) {
        
        emailLabelOutlet.text = scoopUser.email
        accountTypeLabelOutlet.text = scoopUser.userType
        pickupModeLabelOutlet.text = "Pickup Mode Enabled"
        pickupModeLabelOutlet.isHidden = false
        pickUpSwitchOutlet.isOn = scoopUser.isPickUpModeEnabled
        pickUpSwitchOutlet.isHidden = false
        
        guard let imgUrlString = scoopUser.profileImageUrl as? String, let imgUrl = URL(string: imgUrlString)  else {
            print("There was a problem downloading the image.")
            return
        }
        
        ImageService.downloadAndCacheImage(withUrl: imgUrl) { (isdownloaded, image, error) in
            if isdownloaded {
                DispatchQueue.main.async {
                    self.profileImageViewOutlet.image = image
                }
            }
        }
        
        if Auth.auth().currentUser == nil {
            self.loginLogoutButtonOutlet.setTitle("Sign Up / Login", for: .normal)
        } else {
            self.loginLogoutButtonOutlet.setTitle("Log Out", for: .normal)
        }
        
        
    }
    
    
    
    
    
}


// MARK:- Signout functionality
extension LeftSidePanelVC {
    
    private func logout(completion:@escaping(_ success:Bool?) -> ()) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            print("error:\(error.localizedDescription)")
            completion(false)
        }
    }
}
