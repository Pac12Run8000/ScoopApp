//
//  RoundImageView.swift
//  ScoopApp
//
//  Created by Michelle Grover on 12/31/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    
    override func awakeFromNib() {
        setupImageView()
    }

    func setupImageView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }

}
