//
//  EditPasswordViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 7/27/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class EditPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var existingPasswordField: BottomBorderUITextField!
    @IBOutlet weak var newPasswordField: BottomBorderUITextField!
    @IBOutlet weak var confirmPasswordField: BottomBorderUITextField!
    @IBOutlet weak var saveButton: SnailMailTextUIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        existingPasswordField.addBottomLayer()
        newPasswordField.addBottomLayer()
        confirmPasswordField.addBottomLayer()
        
        saveButton.layer.cornerRadius = 5
        
        warningLabel.hide()
        validateSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateSaveButton() {
        if existingPasswordField.text != "" && newPasswordField.text != "" && confirmPasswordField.text != "" {
            saveButton.enable()
        }
        else {
            saveButton.disable()
        }
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        warningLabel.hide()
        validateSaveButton()
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        saveButton.disable()
        
        if newPasswordField.text == confirmPasswordField.text {
        
            let parameters = ["old_password": existingPasswordField.text!, "new_password": newPasswordField.text!]
            
            LoginService.resetPassword(loggedInUser, parameters: parameters, completion: { (error, result) -> Void in
                if let response = result as? String {
                    if response == "Success" {
                        self.passwordChanged()
                    }
                }
                if let response = result as? [String] {
                    if response[0] == "Failure" {
                        let error_message = response[1]
                        self.warningLabel.show(error_message)
                    }
                }
            })
        }
        else {
            warningLabel.show("New passwords must match")
        }
    }
    
    func passwordChanged() {
        self.performSegueWithIdentifier("passwordChanged", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passwordChanged" {
            let viewProfileViewController = segue.destinationViewController as? ViewProfileViewController
            viewProfileViewController!.messageLabel.show("Password changed successfully")
            
            // Delay the dismissal by 5 seconds
            let delay = 5.0 * Double(NSEC_PER_SEC)
            var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                viewProfileViewController!.messageLabel.hide()
            })
        }
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
