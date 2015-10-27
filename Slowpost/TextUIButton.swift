//
//  SnailMailTextUIButton.swift
//  Slowpost
//
//  Created by Evan Waters on 6/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class TextUIButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func disable() {
        enabled = false
        backgroundColor = slowpostDarkGrey
    }
    
    func enable() {
        enabled = true
        backgroundColor = slowpostDarkGreen
    }

}
