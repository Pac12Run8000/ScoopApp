//
//  LoginVC.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/6/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import Firebase


class LoginVC: UIViewController {

    @IBOutlet weak var emailTextFieldOutlet: RoundedCornerTextField!
    @IBOutlet weak var passwordTextFieldOutlet: RoundedCornerTextField!
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var authButtonOutlet: RoundedShadowButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        
        emailTextFieldOutlet.delegate = self
        passwordTextFieldOutlet.delegate = self
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @IBAction func authButtonAction(_ sender: Any) {
        
    }
    
}


// MARK:- Remove keyboard from view
extension LoginVC {
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        self.view.addGestureRecognizer(tap)
    }
    
    
    @objc func handleScreenTap() {
           self.view.endEditing(true)
       }
}

// MARK:- Textfield delegate functionality
extension LoginVC: UITextFieldDelegate {
    
    
}
