//
//  AddEmailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 10/5/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class AddEmailViewController: BaseViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailField: BottomBorderUITextField!
    @IBOutlet weak var submitButton: TextUIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var submitButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        validateSubmitButton()
    }
    
    //MARK: Setup
    
    private func configure() {
        submitButton.layer.cornerRadius = 5
        formatButtons()
        warningLabel.hide()
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emailField.addBottomLayer()
    }
    
    private func formatButtons() {
        cancelButton.setImage(UIImage(named: "close")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        cancelButton.tintColor = slowpostDarkGrey
    }
    
    private func formatForiPhone4S() {
        submitButtonHeight.constant = 30
        emailField.font = emailField.font!.fontWithSize(15.0)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addEmail()
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: User actions
    
    
    @IBAction func editingChanged(sender: AnyObject) {
        warningLabel.hide()
        validateSubmitButton()
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }

    @IBAction func submitButtonPressed(sender: AnyObject) {
        Flurry.logEvent("Added_email_manually")
        addEmail()
    }
    
    //MARK: Private
    
    private func validateSubmitButton() {
        if emailField.text != "" {
            submitButton.enable()
        }
        else {
            submitButton.disable()
        }
    }
    
    private func addEmail() {
        performSegueWithIdentifier("emailAdded", sender: nil)
    }
    

}
