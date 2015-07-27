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
            
            DataManager.resetPassword(loggedInUser, parameters: parameters, completion: { (error, result) -> Void in
                if let response = result as? String {
                    if response == "Success" {
                        println("Updated succeeded")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
