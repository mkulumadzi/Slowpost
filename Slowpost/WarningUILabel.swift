//
//  WarningUILabel.swift
//  Slowpost
//
//  Created by Evan Waters on 6/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class WarningUILabel: UILabel {
    
    func hide() {
        text = ""
        backgroundColor = UIColor.clearColor()
        
    }
    
    func show(message: String) {
        text = message
        backgroundColor = slowpostBlack
    }
    
}
