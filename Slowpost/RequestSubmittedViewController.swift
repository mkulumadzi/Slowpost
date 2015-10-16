//
//  RequestSubmittedViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 10/16/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class RequestSubmittedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delay(3.0) {
            self.performSegueWithIdentifier("passwordResetEmailSent", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
