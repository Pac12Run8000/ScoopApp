//
//  LoginVC.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/6/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import Firebase

enum LoginState {
    case Login
    case Register
}


class LoginVC: UIViewController {

    @IBOutlet weak var emailTextFieldOutlet: RoundedCornerTextField!
    @IBOutlet weak var passwordTextFieldOutlet: RoundedCornerTextField!
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var authButtonOutlet: RoundedShadowButton!
    @IBOutlet weak var emailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    var loginState:LoginState? {
        didSet {
            if loginState == LoginState.Login {
                animateConstraint(constant: 8, view: self.view, constraint: emailTopConstraint)
                animateImageView(hidden: true)
                animateAuthButton(text: "Login")
            } else if loginState == LoginState.Register {
                animateConstraint(constant: 88, view: self.view, constraint: emailTopConstraint)
                animateImageView(hidden: false)
                animateAuthButton(text: "Register")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        
        emailTextFieldOutlet.delegate = self
        passwordTextFieldOutlet.delegate = self
        
        displayImageView()
        profileImageView.alpha = 0.0
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @IBAction func authButtonAction(_ sender: Any) {

    }
    
    @IBAction func segmentControlAction(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            loginState = segment.selectedSegmentIndex == 0 ? LoginState.Login : LoginState.Register
        }
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
// MARK:- Animation functionality
extension LoginVC {
    
    func animateAuthButton(text:String) {
        self.authButtonOutlet.setTitle(text, for: .normal)
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    func animateConstraint(constant:CGFloat, view:UIView, constraint:NSLayoutConstraint) {
        constraint.constant = constant
        UIView.animate(withDuration: 0.4) {
            view.layoutIfNeeded()
        }
    }
    
    func animateImageView(hidden:Bool) {
        if (profileImageView.alpha == 0.0) {
           DispatchQueue.main.async {
               UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
                self.profileImageView.alpha = 1.0
               }, completion: nil)
           }
       } else {
           DispatchQueue.main.async {
               UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {
                self.profileImageView.alpha = 0.0
               }, completion: nil)
           }
       }
    }
    
    func displayImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = UIColor.red.cgColor
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 2
    }
    
}
