//
//  UsernameViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/13/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController {

    @IBOutlet weak var usernameTextField: BottomBorderUITextField!
    @IBOutlet weak var passwordTextField: BottomBorderUITextField!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nextButton: UIButton!
    
    var name:String!
    var email:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        usernameTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        
        warningLabel.hide()
        validateNextButton()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateNextButton()
        warningLabel.hide()
    }
    
    func validateNextButton() {
        if usernameTextField.text != "" && passwordTextField.text != "" {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enterPhone" {
            let destinationViewController = segue.destinationViewController as? PhoneEntryViewController
            
            destinationViewController!.name = name
            destinationViewController!.email = email
            destinationViewController!.username = usernameTextField.text
            destinationViewController!.password = passwordTextField.text
        }
    }

}
