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
        self.backgroundColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
    }
    
    func enable() {
        self.enabled = true
        self.backgroundColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
    }

}
