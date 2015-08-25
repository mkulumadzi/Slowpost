//
//  UsernameViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/13/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: BottomBorderUITextField!
    @IBOutlet weak var passwordTextField: BottomBorderUITextField!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var nextButton: TextUIButton!
  
    var name:String!
    var email:String!

    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToUsername: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToPassword: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToNext: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Username_View_Opened")
        
        passwordTextField.delegate = self
        
        usernameTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        
        warningLabel.hide()
        validateNextButton()
        
        nextButton.layer.cornerRadius = 5
        
        if deviceType == "iPhone 4S" {
            self.formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        
        verticalSpaceToTitle.constant = 10
        verticalSpaceToUsername.constant = 10
        verticalSpaceToPassword.constant = 10
        verticalSpaceToNext.constant = 10
        buttonHeight.constant = 30
        
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
            nextButton.enable()
        }
        else {
            nextButton.enable()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        checkUsernameAvailability(self)
        return true
    }
    
    @IBAction func checkUsernameAvailability(sender: AnyObject) {
        nextButton.disable()
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
