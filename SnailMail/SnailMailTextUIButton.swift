//
//  SnailMailTextUIButton.swift
//  SnailMail
//
//  Created by Evan Waters on 6/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SnailMailTextUIButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func disable() {
        self.enabled = false
        self.backgroundColor = UIColor.darkGrayColor()
    }
    
    func enable() {
        self.enabled = true
        self.backgroundColor = UIColor(red: 51/255, green: 153/255, blue: 102/255, alpha: 1.0)
    }

}
