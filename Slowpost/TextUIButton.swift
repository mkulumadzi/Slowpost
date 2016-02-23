//
//  SnailMailTextUIButton.swift
//  Slowpost
//
//  Created by Evan Waters on 6/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class TextUIButton: UIButton {
    
    func disable() {
        enabled = false
        backgroundColor = slowpostDarkGrey
    }
    
    func enable() {
        enabled = true
        backgroundColor = slowpostDarkGreen
    }

}
