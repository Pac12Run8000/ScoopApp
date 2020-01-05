//
//  CenterVCDelegate.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/2/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

protocol CenterVCDelegate {
    func toggleLeftPanel()
    func addLeftPanelViewController()
    func animateLeftPanel(ShouldExpand:Bool)
}
