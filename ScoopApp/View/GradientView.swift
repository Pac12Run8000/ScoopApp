//
//  GradientView.swift
//  ScoopApp
//
//  Created by Michelle Grover on 12/31/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class GradientView: UIView {

   let gradient = CAGradientLayer()
    
    override func awakeFromNib() {
        setupGradientView()
    }
    
    func setupGradientView() {
        gradient.frame = self.bounds
        gradient.colors = [UIColor.white.cgColor,UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations = [0.8, 1.0]
//        self.layer.addSublayer(gradient)
        self.layer.insertSublayer(gradient, at: 0)
    }

}
