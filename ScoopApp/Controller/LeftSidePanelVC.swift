//
//  LeftSidePanelVC.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/1/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

class LeftSidePanelVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func signUpLoginBtnActionPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginVCSegue", sender: self)
    }
    
    

}
