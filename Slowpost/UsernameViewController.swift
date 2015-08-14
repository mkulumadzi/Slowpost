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
    
    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToUsername: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToPassword: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        usernameTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        
        warningLabel.hide()
        validateNextButton()
        
        if deviceType == "iPhone 4S" {
            self.formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        
        verticalSpaceToTitle.constant = 30
        verticalSpaceToUsername.constant = 10
        verticalSpaceToPassword.constant = 10
        
        usernameTextField.font = usernameTextField.font.fontWithSize(15.0)
        passwordTextField.font = passwordTextField.font.fontWithSize(15.0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func checkUsernameAvailability(sender: AnyObject) {
        nextButton.enabled = false
        let params = ["username": usernameTextField.text!]
        
        PersonService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let availability = result!.valueForKey("username") as? String {
                if availability == "available" {
                    self.performSegueWithIdentifier("enterPhone", sender: nil)
                }
                else {
                    self.warningLabel.show("An account with that username already exists.")
                }
            }
            else {
                println("Unexpected result when checking field availability")
            }
        })
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
