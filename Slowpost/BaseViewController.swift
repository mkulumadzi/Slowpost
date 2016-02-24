//
//  BaseViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 2/23/16.
//  Copyright © 2016 Evan Waters. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var warningLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: UI Accessories
    
    func addWarningLabel() {
        warningLabel = UILabel()
        view.addSubview(warningLabel)
        warningLabel.backgroundColor = slowpostBlack
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.font = UIFont(name: "OpenSans", size: 15.0)
        warningLabel.textAlignment = .Center
        addEdgeConstraintsToItem(warningLabel)
        warningLabel.alpha = 0.0
    }

}
