//
//  AvatarView.swift
//  Slowpost
//
//  Created by Evan Waters on 10/8/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class AvatarView: UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        layer.cornerRadius = 15
    }

}
