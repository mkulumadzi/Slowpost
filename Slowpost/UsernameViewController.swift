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
    @IBOutlet weak var confirmPasswordTextField: BottomBorderUITextField!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var nextButton: TextUIButton!
    @IBOutlet weak var termsTextView: UITextView!
    
    var givenName:String!
    var familyName:String!
    var email:String!

    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToNext: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Username_View_Opened")
        passwordTextField.delegate = self
        configure()
        validateNextButton()
    }
    
    //MARK: Setup
    
    private func configure() {
        warningLabel.hide()
        nextButton.layer.cornerRadius = 5
        formatTermsString()
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
    }
    
    private func formatTermsString() {
        termsTextView.text = ""
        let termsString = "By clicking 'Sign up' I confirm I agree to the Terms and Privacy Policy."
        let greenColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
        let darkGreenColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        let privacyLink = NSURL(string: "https://slowpost.me/#/privacy")
        let termsLink = NSURL(string: "https://slowpost.me/#/terms")
        
        let termsMutableString = NSMutableAttributedString(string: termsString, attributes: [NSFontAttributeName : UIFont(name: "OpenSans", size: 13)!, NSForegroundColorAttributeName : greenColor])
        termsMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Semibold", size: 13)!, range: NSRange(location: 47, length: 5))
        termsMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Semibold", size: 13)!, range: NSRange(location: 57, length: 14))
        
        termsMutableString.addAttribute(NSLinkAttributeName, value: termsLink!, range: NSRange(location: 47, length: 5))
        termsMutableString.addAttribute(NSLinkAttributeName, value: privacyLink!, range: NSRange(location: 57, length: 14))
        
        termsTextView.attributedText = termsMutableString
        termsTextView.linkTextAttributes = [NSForegroundColorAttributeName: darkGreenColor]
    }
    
    private func formatForiPhone4S() {
        verticalSpaceToTitle.constant = 10
        verticalSpaceToNext.constant = 10
        buttonHeight.constant = 30
        
        usernameTextField.font = usernameTextField.font!.fontWithSize(15.0)
        passwordTextField.font = passwordTextField.font!.fontWithSize(15.0)
        confirmPasswordTextField.font = confirmPasswordTextField.font!.fontWithSize(15.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        validateNextButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        usernameTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        confirmPasswordTextField.addBottomLayer()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    private func validateNextButton() {
        if usernameTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
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
    
    //MARK: User actions
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateNextButton()
        warningLabel.hide()
    }
    
    @IBAction func checkUsernameAvailability(sender: AnyObject) {
        nextButton.disable()
        if passwordsMatch() {
            let params = ["username": usernameTextField.text!]
            
            LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
                if let error = error {
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
        else {
            self.warningLabel.show("Passwords must match.")
        }
    }
    
    //MARK: Private
    
    private func passwordsMatch() -> Bool {
        if passwordTextField.text! == confirmPasswordTextField.text! {
            return true
        }
        else {
            return false
        }
    }

    
    private func signUp() {
        
        let newPersonURL = "\(PostOfficeURL)person/new"
        let username = usernameTextField.text!
        let password = passwordTextField.text!
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
                else {
                    print(response)
                }
            }
            else {
                print("Unexpected result creating new account")
            }
        })
    }

}
