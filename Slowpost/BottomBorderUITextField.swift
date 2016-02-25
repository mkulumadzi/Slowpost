//
//  BottomBorderUITextField.swift
//  Slowpost
//
//  Created by Evan Waters on 7/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class BottomBorderUITextField: UITextField {
    
    func addBottomLayer() {

        let border = CALayer()
        let thickness = CGFloat(1.0)
        border.borderColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: frame.size.height - thickness, width:  frame.size.width, height: frame.size.height)
        
        border.borderWidth = thickness
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
    
    func addWhiteBottomLayer() {
        let border = CALayer()
        let thickness = CGFloat(1.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: frame.size.height - thickness, width:  frame.size.width, height: frame.size.height)
        border.borderWidth = thickness
        layer.addSublayer(border)
        layer.masksToBounds = true
    }

}
