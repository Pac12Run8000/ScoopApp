//
//  RoundedCornerTextField.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/6/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

class RoundedCornerTextField: UITextField {
    

    
    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
//        self.layer.cornerRadius = self.frame.height / 2
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
    }
    
    
    
    
    
}
