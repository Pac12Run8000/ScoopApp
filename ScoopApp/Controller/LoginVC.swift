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

enum UserType:String {
    case Driver = "Driver"
    case Passenger = "Passenger"
}


protocol LoginDelegate:class {
    func setUserProfile(scoopUser:ScoopUpUser)
}


class LoginVC: UIViewController {

    @IBOutlet weak var emailTextFieldOutlet: RoundedCornerTextField!
    @IBOutlet weak var passwordTextFieldOutlet: RoundedCornerTextField!
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var driversPassengersSegmentedControl: UISegmentedControl!
    @IBOutlet weak var authButtonOutlet: RoundedShadowButton!
    @IBOutlet weak var emailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    weak var loginDelegate:LoginDelegate?
    
    
    
    
    var loginState:LoginState? {
        didSet {
            if loginState == LoginState.Login {
                animateConstraint(constant: 10, view: self.view, constraint: emailTopConstraint)
                imageViewAnimate(imgView: profileImageView, alpha: 1.0)
                animateAuthButton(text: "Login")
                segmentedControlFadeoutAnimation(control: driversPassengersSegmentedControl, alpha: 1.0)
                usernameTextField.isHidden = true
                emailTextFieldOutlet.becomeFirstResponder()
            } else if loginState == LoginState.Register {
                animateConstraint(constant: 175, view: self.view, constraint: emailTopConstraint)
                imageViewAnimate(imgView: profileImageView, alpha: 0.0)
                animateAuthButton(text: "Register")
                segmentedControlFadeoutAnimation(control: driversPassengersSegmentedControl, alpha: 0.0)
                usernameTextField.isHidden = false
                usernameTextField.becomeFirstResponder()
            }
        }
    }
    
    var userType:UserType? {
        didSet {
            if userType == UserType.Driver {
                
            } else if userType == UserType.Passenger {
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        
        emailTextFieldOutlet.delegate = self
        passwordTextFieldOutlet.delegate = self
        
        setupImageView()
        
        
        loginState = .Login
        userType = .Driver
        
        logout { (succeed) in
            if succeed! {

                print("Logged Out!!!")
            } else {
                print("Logout failed.")
            }
        }
        
        
    }
    
   
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    @IBAction func authButtonAction(_ sender: Any) {
//        authButtonOutlet.animateButton(shouldLoad: true, with: nil)
        
        if self.loginState == LoginState.Login {
            
            // MARK:- Login functionality
            guard loginValidation(emailField: emailTextFieldOutlet, passwordField: passwordTextFieldOutlet) == true else {
                return
            }
            
            Auth.auth().signIn(withEmail: emailTextFieldOutlet.text!, password: passwordTextFieldOutlet.text!) { [unowned self] (result, error) in
                guard error == nil else {
                    if let description = error?.localizedDescription {
                        self.presentLoginErrorController(title: "Login error", msg: "Error:\(description)", element: nil)
                    }
                    return
                }

                ScoopUpUser.observePassengersAndDriver(uId: (result?.user.uid)!) { (user, succeed) in
//                    print("user:\(user?.uId)", user?.email, user?.isPickUpModeEnabled, user?.userType)
                    
                    guard succeed == true else {
                        print("Unable to successfully retrieve data.")
                        return
                    }
                    
                    guard let user = user else {
                        print("There is no user!")
                        return
                    }
                    
                    self.loginDelegate?.setUserProfile(scoopUser: user)
                }
                self.dismiss(animated: true, completion: nil)
            }
            
        } else if self.loginState == LoginState.Register {
            
            // MARK:- Registration functionality
            guard registrationValidation(imageView: profileImageView, emailField: emailTextFieldOutlet, passwordField: passwordTextFieldOutlet) == true else {
                return
            }
            
            Auth.auth().createUser(withEmail: emailTextFieldOutlet.text!, password: passwordTextFieldOutlet.text!) { [unowned self] (result, error) in
                guard error == nil else {
                    if let description = error?.localizedDescription {
                        self.presentLoginErrorController(title: "registration error", msg: "There was an error creating the user:\(description)", element: nil)
                    }
                    return
                }
                print("User creation was successful!!!")
                self.storeProfileDataAndImage(email: self.emailTextFieldOutlet.text!, userType: UserType(rawValue: (self.userType?.rawValue)!)!, profileImage: self.profileImageView.image!, username: self.usernameTextField.text!)
            }
            
            
        }
    }
    
    @IBAction func segmentControlAction(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            loginState = segment.selectedSegmentIndex == 0 ? LoginState.Login : LoginState.Register
        }
    }
    
    @IBAction func userTypeSegmentedControl(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            userType = segment.selectedSegmentIndex == 0 ? UserType.Driver : UserType.Passenger
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

// MARK:- Textfield delegate functionality / Keyboard move functionality
extension LoginVC: UITextFieldDelegate {
    
    
    
}
// MARK:- Animation functionality
extension LoginVC {
    
    
    func segmentedControlFadeoutAnimation(control:UISegmentedControl, alpha: CGFloat) {
        if (alpha == 0.0) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                    control.alpha = 1.0
                }, completion: nil)
            }
        } else if (alpha == 1.0) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                    control.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
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
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                    imgView.alpha = 1.0
                }, completion: nil)
            }
        } else if (alpha == 1.0) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
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
        } else if let username = usernameTextField.text, let t_username = username.trimmingCharacters(in: .whitespacesAndNewlines) as? String, t_username.isEmpty {
            presentLoginErrorController(title: "login Error", msg: "Please enter a username so that your friends will know who you are.", element: usernameTextField)
            return false
        } else if (emailField.text!.isEmpty) {
            presentLoginErrorController(title: "login error", msg: "Please enter an email.", element: emailTextFieldOutlet)
            return false
        } else if (!isValidEmailAddress(testStr: emailTextFieldOutlet.text!)) {
            presentLoginErrorController(title: "login error", msg: "Your email was invalid. Try again.", element: emailTextFieldOutlet)
            return false
        } else if let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines), password.isEmpty {
            presentLoginErrorController(title: "login error", msg: "Please enter a password.", element: passwordTextFieldOutlet)
            return false
        } else if let password = passwordTextFieldOutlet.text, password.count <= 6 {
            presentLoginErrorController(title: "login error", msg: "Please enter a valid password. The password has to be at least 6 characters long.", element: passwordTextFieldOutlet)
            return false
        } else if let password = passwordField.text, password.contains(" ") {
             presentLoginErrorController(title: "login error", msg: "Please enter a valid password. Remove all whitespaces.", element: passwordTextFieldOutlet)
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
        } else if let password = passwordTextFieldOutlet.text, password.count <= 6 {
            presentLoginErrorController(title: "login error", msg: "Please enter a valid password. The password has to be at least 6 characters long.", element: passwordTextFieldOutlet)
            return false
        } else if let password = passwordField.text, password.contains(" ") {
             presentLoginErrorController(title: "login error", msg: "Please enter a valid password. Remove all whitespaces.", element: passwordTextFieldOutlet)
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

// MARK:- Logout functionality
extension LoginVC {
    
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


// MARK:- Store the Login information to Firebase
extension LoginVC {
    
    private func storeProfileDataAndImage(email:String, userType:UserType, profileImage:UIImage, username:String) {
        
        let storageRef = Storage.storage().reference().child("profileImages").child("\(NSUUID().uuidString).jpg")
        storageRef.putData(profileImage.jpegData(compressionQuality: 0.1)!, metadata: nil) { (metaData, error) in
            
            guard error == nil else {
                print("storage error:\(error?.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("download error:\(error?.localizedDescription)")
                    return
                }
                
                guard (url?.absoluteString) != nil else {
                    print("There was an error with absolute string.")
                    return
                }
                
                let userID = Auth.auth().currentUser?.uid as! String
                let ref = Database.database().reference()
                let userRef = ref.child(userType.rawValue).child(userID)
                
                let values = ["username": username, "email": email, "profileImageUrl": url?.absoluteString, "isPickUpModeEnabled": false] as [String : AnyObject]
                
                userRef.updateChildValues(values) { [unowned self] (err, reference) in
                    guard err == nil else {
                        if let errdescription = err?.localizedDescription {
                            print("error:\(errdescription)")
                        }
                        return
                    }
                    
                    print("Data saved to firebase")
                    
                    if let userId = Auth.auth().currentUser?.uid {
                        ScoopUpUser.observePassengersAndDriver(uId: userId) { (scoopUser, succeed) in
                            if (succeed) {
                                self.loginDelegate?.setUserProfile(scoopUser: scoopUser!)
                                self.dismiss(animated: true , completion: nil)
                            }
                        }
                    } else {
                        print("Noone is logged in.")
                        self.presentLoginErrorController(title: "Registration error", msg: "You are not logged in.", element: nil)
                    }
                }
                
            }
        }
        
    
       
    }
}
// MARK:- Error code notes
extension LoginVC {
    
    /*
    guard let errorCode = AuthErrorCode(rawValue: 0) else {
        return
    }
    */
    
}



