//
//  PasswordFBController.swift
//  Slowpost
//
//  Created by Evan Waters on 12/8/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class PasswordFBController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: BottomBorderUITextField!
    @IBOutlet weak var confirmPasswordTextField: BottomBorderUITextField!
    
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var signUpButton: TextUIButton!
    @IBOutlet weak var termsTextView: UITextView!
    
    var givenName:String!
    var familyName:String!
    var email:String!
    var username:String!
    
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToSignUp: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Username_View_Opened")
        
        confirmPasswordTextField.delegate = self
        
        warningLabel.hide()
        validateNextButton()
        
        signUpButton.layer.cornerRadius = 5
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
        formatTermsString()
        
    }
    
    func formatTermsString() {
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
    
    func formatForiPhone4S() {
        
        buttonHeight.constant = 30
        verticalSpaceToSignUp.constant = 10
        verticalSpaceToTitle.constant = 10
        
        passwordTextField.font = passwordTextField.font!.fontWithSize(15.0)
        confirmPasswordTextField.font = confirmPasswordTextField.font!.fontWithSize(15.0)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        validateNextButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        passwordTextField.addBottomLayer()
        confirmPasswordTextField.addBottomLayer()
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
        if passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            signUpButton.enable()
        }
        else {
            signUpButton.disable()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        getFacebookInfoAndSignUp()
        return true
    }
    
    func passwordsMatch() -> Bool {
        if passwordTextField.text! == confirmPasswordTextField.text! {
            return true
        }
        else {
            return false
        }
    }
    
    
    @IBAction func signUpPressed(sender: AnyObject) {
        getFacebookInfoAndSignUp()
    }
    
    func getFacebookInfoAndSignUp() {
        if passwordsMatch() {
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil) {
                    print(error)
                }
                else {
                    let facebookId = result!.valueForKey("id") as! String
                    let name = result!.valueForKey("name") as! String
                    let username = self.username
                    let email = result!.valueForKey("email") as! String
                    self.signUp(facebookId, name: name, username: username, email: email)
                }
            })
        }
        else {
            self.warningLabel.show("Passwords must match.")
        }
        
    }
    
    func signUp(facebookId: String, name: String, username: String, email: String) {
        signUpButton.disable()
        
        let newPersonURL = "\(PostOfficeURL)person/new"
        let fullNameArray = name.characters.split{$0 == " "}.map(String.init)
        let givenName = fullNameArray[0]
        let familyName = fullNameArray[1]
        let password = passwordTextField.text!
        let facebookToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        let parameters = ["given_name": "\(givenName)", "family_name": "\(familyName)", "username": "\(username)", "email": "\(email)", "password": "\(password)", "facebook_id": "\(facebookId)", "facebook_token": "\(facebookToken)"]
        
        let headers:[String: String] = ["Authorization": "Bearer \(appToken)", "Accept": "application/json"]
        
        RestService.postRequest(newPersonURL, parameters: parameters, headers: headers, completion: { (error, result) -> Void in
            if let response = result as? [AnyObject] {
                if response[0] as? Int == 201 {
                    LoginService.logInWithFacebook({ (error, result) -> Void in
                        self.performSegueWithIdentifier("facebookSignUpComplete", sender: nil)
                    })
                }
                else if let error_message = response[1] as? String {
                    self.warningLabel.show(error_message)
                }
                else {
                    print(response)
                }
            }
        })
    }


}
