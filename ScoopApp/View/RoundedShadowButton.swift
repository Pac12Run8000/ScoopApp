//
//  RoundedShadowButton.swift
//  ScoopApp
//
//  Created by Michelle Grover on 12/31/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {
    
    var originalSize:CGRect?

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        originalSize = self.frame
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 20.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
    }
    
    func animateButton(shouldLoad:Bool, with message:String?) {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.color = .white
        spinner.alpha = 0.0
        spinner.hidesWhenStopped = true
        spinner.tag = 21
        
        if shouldLoad {
            self.addSubview(spinner)
            
            
            self.setTitle("", for: .normal)
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.cornerRadius = self.frame.height / 2
                self.frame = CGRect(x: self.frame.midX - (self.frame.height / 2), y: self.frame.origin.y, width: self.frame.height, height: self.frame.height)
                
            }) { (finished) in
                if finished {
                    spinner.startAnimating()
                    spinner.center = CGPoint(x: self.frame.width / 2 + 1, y: self.frame.height / 2 + 1)
                    spinner.fadeTo(alphaValue: 1.0, withDuration: 0.2)

                }
            }
            self.isUserInteractionEnabled = false
        } else {
            self.isUserInteractionEnabled = true
            
            for subview in self.subviews {
                if spinner.tag == 21 {
                    subview.removeFromSuperview()
                }
            }
            
            UIView.animate(withDuration: 0.2) {
                self.layer.cornerRadius = 5.0
                self.frame = self.originalSize!
                self.setTitle(message, for: .normal)
            }
        }
        
        
    }

}
