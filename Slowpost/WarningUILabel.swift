//
//  WarningUILabel.swift
//  Slowpost
//
//  Created by Evan Waters on 6/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class WarningUILabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func hide() {
        text = ""
        backgroundColor = UIColor.clearColor()
        
    }
    
    func show(message: String) {
        text = message
        backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1.0)
    }
    
}
