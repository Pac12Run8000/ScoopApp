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
                imageViewAnimate(imgView: profileImageView, alpha: 1.0)
                animateAuthButton(text: "Login")
            } else if loginState == LoginState.Register {
                animateConstraint(constant: 88, view: self.view, constraint: emailTopConstraint)
                imageViewAnimate(imgView: profileImageView, alpha: 0.0)
                animateAuthButton(text: "Register")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        
        emailTextFieldOutlet.delegate = self
        passwordTextFieldOutlet.delegate = self
        
        setupImageView()
        
        emailTextFieldOutlet.becomeFirstResponder()
        loginState = .Login
        
        
        
        

        
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @IBAction func authButtonAction(_ sender: Any) {
//        authButtonOutlet.animateButton(shouldLoad: true, with: nil)
        
        if self.loginState == LoginState.Login {
            loginValidation(emailField: emailTextFieldOutlet, passwordField: passwordTextFieldOutlet) == true ? print("Sending data") : print("Invalid data")
        } else if self.loginState == LoginState.Register {
            registrationValidation(imageView: profileImageView, emailField: emailTextFieldOutlet, passwordField: passwordTextFieldOutlet) == true ? print("Sending data") : print("Invalid data")
        }
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
    
    private func imageViewAnimate(imgView:UIImageView, alpha:Double) {
        if (alpha == 0.0) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
                    imgView.alpha = 1.0
                }, completion: nil)
            }
        } else if (alpha == 1.0) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
                    imgView.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
    
    

    
    func setupImageView() {
        profileImageView.alpha = 0.0
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = UIColor.red.cgColor
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 2
        
        profileImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionSheetforProfileImage))
        profileImageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
   
    
}
// MARK:- This is the profileImage functionality
extension LoginVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func actionSheetforProfileImage() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        
        let actionSheet = UIAlertController(title: "Get Photos", message: "Camera or Photo Library", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                self.presentLoginErrorController(title: "notification", msg: "There is no camera available on this device.", element: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)

       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImageView.image = originalImage
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK:- Login Error alertcontroller
extension LoginVC {
    
    private func presentLoginErrorController(title:String, msg:String, element:UIControl?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertaction = UIAlertAction(title: "Okay", style: .default) { [weak self] (action) in
            alertController.dismiss(animated: true) {
                guard element != nil else {
                    return
                }
                element!.becomeFirstResponder()
            }
        }
        alertController.addAction(alertaction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK:- Login / Registration error handling
extension LoginVC {
    
    private func registrationValidation(imageView:UIImageView, emailField:UITextField, passwordField:UITextField) -> Bool {
        if (imageView.image == nil) {
            presentLoginErrorController(title: "Registration error", msg: "Select an image for you profile.", element: nil)
            return false
        } else if (emailField.text!.isEmpty) {
            presentLoginErrorController(title: "login error", msg: "Please enter an email.", element: emailTextFieldOutlet)
            return false
        } else if (!isValidEmailAddress(testStr: emailTextFieldOutlet.text!)) {
            presentLoginErrorController(title: "login error", msg: "Your email was invalid. Try again.", element: emailTextFieldOutlet)
            return false
        } else if (passwordField.text!.isEmpty) {
            presentLoginErrorController(title: "login error", msg: "Please enter a password.", element: passwordTextFieldOutlet)
            return false
        } else if (passwordTextFieldOutlet.text!.count <= 6) {
            presentLoginErrorController(title: "login error", msg: "Please enter a valid password. The password has to be at least 6 characters long.", element: passwordTextFieldOutlet)
            return false
        }
        
        return true
    }
    
    private func loginValidation(emailField:UITextField, passwordField:UITextField) -> Bool {
        if (emailField.text!.isEmpty) {
            presentLoginErrorController(title: "login error", msg: "Please enter an email.", element: emailTextFieldOutlet)
            return false
        } else if (!isValidEmailAddress(testStr: emailTextFieldOutlet.text!)) {
            presentLoginErrorController(title: "login error", msg: "Your email was invalid. Try again.", element: emailTextFieldOutlet)
            return false
        } else if (passwordField.text!.isEmpty) {
            presentLoginErrorController(title: "login error", msg: "Please enter a password.", element: passwordTextFieldOutlet)
            return false
        } else if (passwordTextFieldOutlet.text!.count <= 6) {
            presentLoginErrorController(title: "login error", msg: "Please enter a valid password. The password has to be at least 6 characters long.", element: passwordTextFieldOutlet)
            return false
        }
        return true
    }
    
    
    func isValidEmailAddress(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
}
