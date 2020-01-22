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
        
        if let uid = Auth.auth().currentUser?.uid {
            ScoopUpUser.observePassengersAndDriver(uId: uid) { (user, succeed) in
                self.loginLogoutButtonOutlet.setTitle("Log Out", for: .normal)
                self.emailLabelOutlet.text = user?.email
                self.accountTypeLabelOutlet.text = user?.userType
                self.pickUpSwitchOutlet.isOn = user!.isPickUpModeEnabled
                if let urlString = user?.profileImageUrl, let url = URL(string: urlString) {
                    ImageService.downloadAndCacheImage(withUrl: url) { (succeed, image, err) in
                        self.profileImageViewOutlet.image = image
                    }
                }
                
                if user?.userType == "Passenger" {
                    self.pickUpSwitchOutlet.isHidden = true
                    self.pickupModeLabelOutlet.isHidden = true
                } else if user?.userType == "Driver" {
                    self.pickUpSwitchOutlet.isHidden = false
                    self.pickupModeLabelOutlet.isHidden = false
                    self.pickUpSwitchOutlet.isOn = user!.isPickUpModeEnabled
                }
            }
        } else {
            self.loginLogoutButtonOutlet.setTitle("Sign Up / Login", for: .normal)
            
            self.emailLabelOutlet.isHidden = true
            self.accountTypeLabelOutlet.isHidden = true
            self.pickupModeLabelOutlet.isHidden = true
            self.pickUpSwitchOutlet.isHidden = true
            self.profileImageViewOutlet.isHidden = true
            
        }

        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    

    @IBAction func pickUpModeToggleAction(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        ScoopUpUser.togglePickUpMode(uid: uid, toggle: pickUpSwitchOutlet)
    }
    
    
    @IBAction func signUpLoginBtnActionPressed(_ sender: Any) {
        
        if Auth.auth().currentUser == nil {
            self.loginLogoutButtonOutlet.setTitle("Log Out", for: .normal)
            performSegue(withIdentifier: "loginVCSegue", sender: self)
        } else {
            self.loginLogoutButtonOutlet.setTitle("Sign Up / Login", for: .normal)
            
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
        profileImageViewOutlet.isHidden = false
        emailLabelOutlet.isHidden = false
        accountTypeLabelOutlet.isHidden = false
        
        if scoopUser.userType == "Passenger" {
            self.pickUpSwitchOutlet.isHidden = true
            self.pickupModeLabelOutlet.isHidden = true
        } else if scoopUser.userType == "Driver" {
            self.pickUpSwitchOutlet.isHidden = false
            self.pickupModeLabelOutlet.isHidden = false
            self.pickUpSwitchOutlet.isOn = scoopUser.isPickUpModeEnabled
        }
        

        
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
