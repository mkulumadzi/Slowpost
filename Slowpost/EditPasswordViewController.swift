//
//  EditPasswordViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/27/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class EditPasswordViewController: BaseViewController {
    
    @IBOutlet weak var existingPasswordField: BottomBorderUITextField!
    @IBOutlet weak var newPasswordField: BottomBorderUITextField!
    @IBOutlet weak var confirmPasswordField: BottomBorderUITextField!
    @IBOutlet weak var saveButton: TextUIButton!
    @IBOutlet weak var verticalSpaceToNewPasswordLabel1: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToNewPasswordField1: NSLayoutConstraint!
    @IBOutlet weak var saveButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Began_Editing_Password")
        configure()
        validateSaveButton()
    }
    
    //MARK: Setup
    
    private func configure() {
        existingPasswordField.addBottomLayer()
        newPasswordField.addBottomLayer()
        confirmPasswordField.addBottomLayer()
        saveButton.layer.cornerRadius = 5
        addWarningLabel()
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
    }
    
    private func formatForiPhone4S() {
        verticalSpaceToNewPasswordLabel1.constant = 10
        verticalSpaceToNewPasswordField1.constant = 10
        saveButtonHeight.constant = 30
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        existingPasswordField.addBottomLayer()
        newPasswordField.addBottomLayer()
        confirmPasswordField.addBottomLayer()
    }
    
    private func validateSaveButton() {
        if existingPasswordField.text != "" && newPasswordField.text != "" && confirmPasswordField.text != "" {
            saveButton.enable()
        }
        else {
            saveButton.disable()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    //MARK: User actions
    
    @IBAction func editingChanged(sender: AnyObject) {
        hideItem(warningLabel)
        validateSaveButton()
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        saveButton.disable()
        
        if newPasswordField.text == confirmPasswordField.text {
        
            let parameters = ["old_password": existingPasswordField.text!, "new_password": newPasswordField.text!]
            let userId = LoginService.getUserIdFromToken()
            let resetPasswordURL = "\(PostOfficeURL)/person/id/\(userId)/reset_password"
            let headers = ["Authorization": "Bearer \(appToken)"]
            
            RestService.postRequest(resetPasswordURL, parameters: parameters, headers: headers, completion: { (error, result) -> Void in
                if let response = result as? [AnyObject] {
                    if response[0] as? Int == 204 {
                        self.passwordChanged()
                    }
                    else if let error_message = response[1] as? String {
                        self.showLabelWithMessage(self.warningLabel, message: error_message)
                    }
                }
            })
        }
        else {
            self.showLabelWithMessage(self.warningLabel, message: "New passwords must match")
        }
    }
    
    func passwordChanged() {
        Flurry.logEvent("Changed_Password")
        performSegueWithIdentifier("passwordChanged", sender: nil)
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passwordChanged" {
            
            let conversationListViewController = segue.destinationViewController as! ConversationListViewController
            let messageLabel = conversationListViewController.messageLabel
            conversationListViewController.showLabelWithMessage(messageLabel, message: "Password changed successfully")
            
            // Delay the dismissal by 5 seconds
            let delay = 5.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                conversationListViewController.hideItem(messageLabel)
            })
        }
    }

}
