//
//  RequestSubmittedViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 10/16/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class RequestSubmittedViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delay(3.0) {
            self.performSegueWithIdentifier("passwordResetEmailSent", sender: nil)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }

}
