//
//  UsernameFBViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 12/7/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class UsernameFBViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: BottomBorderUITextField!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var nextButton: TextUIButton!
    
    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToNext: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Facebook_Username_View_Opened")
        
        usernameTextField.delegate = self
        
        warningLabel.hide()
        validateNextButton()
        
        nextButton.layer.cornerRadius = 5
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        
        verticalSpaceToTitle.constant = 10
        verticalSpaceToNext.constant = 10
        buttonHeight.constant = 30
        
        usernameTextField.font = usernameTextField.font!.fontWithSize(15.0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        validateNextButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        usernameTextField.addBottomLayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateNextButton()
        warningLabel.hide()
    }
    
    func validateNextButton() {
        if usernameTextField.text! != "" {
            nextButton.enable()
        }
        else {
            nextButton.disable()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        checkUsernameAvailability(self)
        return true
    }
    
    @IBAction func checkUsernameAvailability(sender: AnyObject) {
        nextButton.disable()
        let params = ["username": usernameTextField.text!]
        LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else {
                let availability = result!["username"].stringValue
                if availability == "available" {
                    self.performSegueWithIdentifier("choosePassword", sender: nil)
                }
                else {
                    self.warningLabel.show("An account with that username already exists.")
                }
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "choosePassword" {
            let choosePasswordController = segue.destinationViewController as! PasswordFBController
            choosePasswordController.username = usernameTextField.text!
        }
    }
    
    

}
