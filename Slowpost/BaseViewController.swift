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
        
        let warningLeading = NSLayoutConstraint(item: warningLabel, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let warningTrailing = NSLayoutConstraint(item: warningLabel, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let warningTop = NSLayoutConstraint(item: warningLabel, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 60.0)
        let warningHeight = NSLayoutConstraint(item: warningLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30.0)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([warningLeading, warningTrailing, warningTop, warningHeight])
        
        warningLabel.hidden = true
    }
    
    func showWarningLabel(message: String) {
        warningLabel.text = message
        warningLabel.hidden = false
    }
    
    func hideWarningLabel() {
        warningLabel.hidden = true
    }
    

}
