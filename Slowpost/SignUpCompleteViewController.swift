//
//  SignUpCompleteViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/13/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SignUpCompleteViewController: UIViewController {
    
    
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        gotItButton.layer.cornerRadius = 5

        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        buttonHeight.constant = 30
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
