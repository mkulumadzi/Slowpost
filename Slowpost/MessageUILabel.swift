//
//  MessageUILabel.swift
//  Slowpost
//
//  Created by Evan Waters on 7/27/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MessageUILabel: UILabel {

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
        backgroundColor = slowpostBlack
    }
}
