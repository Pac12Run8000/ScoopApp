//
//  UIViewExt.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/5/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

extension UIView {
    
    func fadeTo(alphaValue:CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
}
