//
//  ContainerVC.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/1/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import QuartzCore


enum SlideOutState {
    case collapsed
    case leftPanelExpanded
}

enum ShowWhichVC {
    case homeVC
}


var showVC:ShowWhichVC = .homeVC

class ContainerVC: UIViewController {
    
    var tap:UITapGestureRecognizer!
    
    var viewController:ViewController!
    var leftVC:LeftSidePanelVC!
    var isHidden:Bool = false
    let centerPanelExpadedOffset:CGFloat = 160
    var centerController:UIViewController!
    
    var currentState:SlideOutState = .collapsed

    override func viewDidLoad() {
        super.viewDidLoad()
        initCenter(screen: showVC)
        
    }
    

    func initCenter(screen: ShowWhichVC) {
        var presentingController:UIViewController
        
        showVC = screen
        if viewController == nil {
            viewController = UIStoryboard.viewController()
            viewController.delegate = self
        }
        
        presentingController = viewController
        
        if let con = centerController as? UIViewController {
            con.view.removeFromSuperview()
            con.removeFromParent()
        }
        
        centerController = presentingController
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
   

}

extension ContainerVC: CenterVCDelegate {
    func toggleLeftPanel() {
        
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        if (notAlreadyExpanded) {
            addLeftPanelViewController()
        }
        animateLeftPanel(ShouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        if (leftVC == nil) {
            leftVC =  UIStoryboard.leftViewController()
            addChildSidePanelViewController(leftVC!)
        }
    }
    
    func addChildSidePanelViewController(_ sidePanelController:LeftSidePanelVC) {
        view.insertSubview(sidePanelController.view, at: 0)
        //addChildSidePanelViewController(sidePanelController)
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    
    @objc func animateLeftPanel(ShouldExpand: Bool) {
        if ShouldExpand {
            isHidden = !isHidden
            animateStatusBar()
            setupWhiteCoverView()
            currentState = .leftPanelExpanded
            animatePanelXPosition(targetPosition: centerController.view.frame.width - centerPanelExpadedOffset)
        } else {
            isHidden = !isHidden
            animateStatusBar()
            hideWhiteCoverView()
            animatePanelXPosition(targetPosition: 0) { (finished) in
                if (finished == true) {
                    self.currentState = .collapsed
                    self.leftVC = nil
                }
            }
        }
    }
    
    func setupWhiteCoverView() {
        let whiteCoverView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor = .white
        whiteCoverView.tag = 25
        self.centerController.view.addSubview(whiteCoverView)
        UIView.animate(withDuration: 0.2) {
            whiteCoverView.alpha = 0.75
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel(ShouldExpand:)))
        tap.numberOfTapsRequired = 1
        self.centerController.view.addGestureRecognizer(tap)
    }
    
    func hideWhiteCoverView() {
        centerController.view.removeGestureRecognizer(tap)
        for subview in self.centerController.view.subviews {
            if subview.tag == 25 {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0.0
                }) { (finished) in
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    func animatePanelXPosition(targetPosition:CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    
    
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func leftViewController() -> LeftSidePanelVC? {
        return mainStoryboard().instantiateViewController(identifier: "LeftSidePanelVC") as? LeftSidePanelVC
    }
    
    class func viewController() -> ViewController? {
        return mainStoryboard().instantiateViewController(identifier: "ViewController") as? ViewController
    }
}
