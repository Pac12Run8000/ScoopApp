//
//  Alertable.swift
//  ScoopApp
//
//  Created by Michelle Grover on 2/10/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

protocol Alertable {}

extension Alertable where Self:UIViewController {
    
    func showAlert(_ title:String, _ msg:String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
}
