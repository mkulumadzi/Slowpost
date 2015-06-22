//
//  SignUpSuccessfulViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/8/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SignUpSuccessfulViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goToMailbox(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "initial", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}