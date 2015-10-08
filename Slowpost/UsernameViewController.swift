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
  
    var givenName:String!
    var familyName:String!
    var email:String!

    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToUsername: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToPassword: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToNext: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
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
        
        usernameTextField.font = usernameTextField.font!.fontWithSize(15.0)
        passwordTextField.font = passwordTextField.font!.fontWithSize(15.0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        validateNextButton()
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
        
        LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else {
                let availability = result!["username"].stringValue
                if availability == "available" {
                    self.signUp()
                }
                else {
                    self.warningLabel.show("An account with that username already exists.")
                }
            }
        })
    }

    
    func signUp() {
        
        let newPersonURL = "\(PostOfficeURL)person/new"
        let username = usernameTextField.text
        let password = passwordTextField.text
        let parameters = ["given_name": "\(givenName)", "family_name": "\(familyName)", "username": "\(username)", "email": "\(email)", "password": "\(password)"]
        
        let headers:[String: String] = ["Authorization": "Bearer \(appToken)", "Accept": "application/json"]
        
        RestService.postRequest(newPersonURL, parameters: parameters, headers: headers, completion: { (error, result) -> Void in
            if let response = result as? [AnyObject] {
                if response[0] as? Int == 201 {
                    let parameters = ["username": "\(username)", "password": "\(password)"]
                    LoginService.logIn(parameters, completion: { (error, result) -> Void in
                        self.performSegueWithIdentifier("signUpComplete", sender: nil)
                    })
                }
                else if let error_message = response[1] as? String {
                    self.warningLabel.show(error_message)
                }
            }
        })
    }

}
