//
//  MessageUILabel.swift
//  Snailtale
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
        self.text = ""
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    func show(message: String) {
        self.text = message
        self.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
    }
}
