//
//  AddEmailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 10/5/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class AddEmailViewController: UIViewController {
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailField: BottomBorderUITextField!
    @IBOutlet weak var submitButton: TextUIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    
    @IBOutlet weak var submitButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.addBottomLayer()
        submitButton.layer.cornerRadius = 5
        
        validateSubmitButton()
        warningLabel.hide()
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }

    }
    
    func formatForiPhone4S() {
        submitButtonHeight.constant = 30
        emailField.font = emailField.font!.fontWithSize(15.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addEmail()
        return true
    }
    
    
    @IBAction func editingChanged(sender: AnyObject) {
        warningLabel.hide()
        validateSubmitButton()
    }
    
    func validateSubmitButton() {
        if emailField.text != "" {
            submitButton.enable()
        }
        else {
            submitButton.disable()
        }
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    @IBAction func submitButtonPressed(sender: AnyObject) {
        addEmail()
    }
    
    func addEmail() {
        performSegueWithIdentifier("emailAdded", sender: nil)
    }
    

}
