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
    
    
    
    var loginState:LoginState? {
        didSet {
            if loginState == LoginState.Login {
                animateView(constant: 8, view: self.view, constraint: emailTopConstraint)

            } else if loginState == LoginState.Register {
                 animateView(constant: 88, view: self.view, constraint: emailTopConstraint)
            }
        }
    }
    
    
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
    
    func animateView(constant:CGFloat, view:UIView, constraint:NSLayoutConstraint) {
        constraint.constant = constant
        UIView.animate(withDuration: 0.4) {
            view.layoutIfNeeded()
        }
    }
    
}
