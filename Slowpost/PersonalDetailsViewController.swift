//
//  PersonalDetailsViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class PersonalDetailsViewController: BaseViewController, UITextFieldDelegate {
    
    var email:String?

    @IBOutlet weak var givenNameTextField: BottomBorderUITextField!
    @IBOutlet weak var familyNameTextField: BottomBorderUITextField!
    @IBOutlet weak var emailTextField: BottomBorderUITextField!
    @IBOutlet weak var nextButton: TextUIButton!
    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToNext: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Personal_Details_View_Opened")
        emailTextField.delegate = self
        configure()
        validateNextButton()
    }
    
    //MARK: Setup
    
    private func configure() {
        nextButton.layer.cornerRadius = 5
        addWarningLabel()
        
        if let email = email {
            emailTextField.text = email
        }
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
    }
    
    func formatForiPhone4S() {
        verticalSpaceToTitle.constant = 10
        verticalSpaceToNext.constant = 10
        buttonHeight.constant = 30
    
        givenNameTextField.font = givenNameTextField.font!.fontWithSize(15.0)
        familyNameTextField.font = familyNameTextField.font!.fontWithSize(15.0)
        emailTextField.font = emailTextField.font!.fontWithSize(15.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        validateNextButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        givenNameTextField.addBottomLayer()
        familyNameTextField.addBottomLayer()
        emailTextField.addBottomLayer()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    private func validateNextButton() {
        if (givenNameTextField.text != "" || familyNameTextField.text != "") && emailTextField.text != "" {
            nextButton.enable()
        }
        else {
            nextButton.disable()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        checkEmailAvailability(self)
        return true
    }
    
    //MARK: User actions
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateNextButton()
        hideItem(warningLabel)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        Flurry.logEvent("Signup_Cancelled")
        dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func checkEmailAvailability(sender: AnyObject) {
        nextButton.disable()
        let params = ["email": emailTextField.text!]
        
        LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if let error = error {
                print(error)
            }
            else {
                let availability = result!["email"].stringValue
                if availability == "available" {
                    self.performSegueWithIdentifier("enterUsername", sender: nil)
                }
                else {
                    self.showLabelWithMessage(self.warningLabel, message: "An account with that email already exists.")
                }
            }
        })
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enterUsername" {
            let destinationViewController = segue.destinationViewController as? UsernameViewController
            destinationViewController!.givenName = givenNameTextField.text!
            destinationViewController!.familyName = familyNameTextField.text!
            destinationViewController!.email = emailTextField.text!
        }
    }
    
}