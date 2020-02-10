//
//  UIViewControllerExt.swift
//  ScoopApp
//
//  Created by Michelle Grover on 2/9/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func shouldPresentLoadingView(status:Bool) {
        var fadeView:UIView?
        
        if (status) {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = UIColor(red: 2/255, green: 64/255, blue: 89/255, alpha: 1.0)
            fadeView?.alpha = 0.0
            fadeView?.tag = 99
            
            let spinner = UIActivityIndicatorView()
            spinner.color = UIColor.white
            spinner.style = .large
            spinner.center = view.center
            
            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            
            spinner.startAnimating()
            fadeView?.fadeTo(alphaValue: 0.7, withDuration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0.0
                    }) { (finished) in
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}
