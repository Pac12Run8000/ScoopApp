//
//  CircleView.swift
//  ScoopApp
//
//  Created by Michelle Grover on 12/31/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class CircleView: UIView {

    @IBInspectable var borderColor:UIColor? {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = 1.5
        self.layer.borderColor = borderColor?.cgColor
    }

}
