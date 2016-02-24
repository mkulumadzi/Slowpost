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
    var messageLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func addWarningLabel() {
        warningLabel = initializeWarningLabel()
    }
    
    func addMessageLabel() {
        messageLabel = initializeMessageLabel()
    }

}
