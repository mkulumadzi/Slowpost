//
//  StartViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 12/4/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import SwiftyJSON

class StartViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: BottomBorderUITextField!
    @IBOutlet weak var nextButton: TextUIButton!
    
    @IBOutlet weak var shadedView: UIView!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    var loginView:FBSDKLoginButton!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logOutOfFacebookIfNecessary()
        
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        
        Flurry.logEvent("Login_Screen_Opened")
        
        addFacebookLoginButton()
        
        emailTextField.delegate = self
        
        nextButton.layer.cornerRadius = 5
        
        validateNextButton()
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
        shadedView.hidden = true
        
    }
    
    func formatForiPhone4S() {
        nextButtonHeight.constant = 30
        emailTextField.font = emailTextField.font!.fontWithSize(15.0)
    }
    
    func logOutOfFacebookIfNecessary() {
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emailTextField.addBottomLayer()
    }
    
    func addFacebookLoginButton() {
        loginView = FBSDKLoginButton()
        loginView.layer.cornerRadius = 5
        view.addSubview(loginView)
        
        let loginViewWidth = NSLayoutConstraint(item: loginView, attribute: .Width, relatedBy: .Equal, toItem: nextButton, attribute: .Width, multiplier: 1.0, constant: 0.0)
        let loginViewHeight = NSLayoutConstraint(item: loginView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0)
        let loginViewTop = NSLayoutConstraint(item: loginView, attribute: .Top, relatedBy: .Equal, toItem: nextButton, attribute: .Bottom, multiplier: 1.0, constant: 30.0)
        let loginViewAlignCenterX = NSLayoutConstraint(item: loginView, attribute: .CenterX, relatedBy: .Equal, toItem: nextButton, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        
        loginView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([loginViewWidth, loginViewHeight, loginViewTop, loginViewAlignCenterX])
        
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            print(error)
        }
        else {
            getUserInfoFromFacebook()
        }
    }
    
//    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
//                return true
//    }
    
    func getUserInfoFromFacebook() {
        shadedView.hidden = false
        view.bringSubviewToFront(shadedView)
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                print(error)
                self.shadedView.hidden = true
            }
            else {
                self.completeSignupWithFacebookResult(result)
            }
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        checkForEmailMatch(self)
        return true
    }
    
    @IBAction func checkForEmailMatch(sender: AnyObject) {
        nextButton.disable()
        let params = ["email": emailTextField.text!]
        
        LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else {
                let availability = result!["email"].stringValue
                if availability == "available" {
                    self.performSegueWithIdentifier("signUp", sender: nil)
                }
                else {
                    // Need to save users' facebook ID so that we know they have logged in this way before
                    self.performSegueWithIdentifier("logIn", sender: nil)
                }
            }
        })
    }
    
    func completeSignupWithFacebookResult(result: AnyObject) {
        let email = result.valueForKey("email") as! String
        let params = ["email": email]
        LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if error != nil {
                self.shadedView.hidden = true
                print(error)
            }
            else {
                let availability = result!["email"].stringValue
                if availability == "available" {
                    self.shadedView.hidden = true
                    self.performSegueWithIdentifier("chooseUsername", sender: nil)
                }
                else {
                    LoginService.logInWithFacebook({ (error, result) -> Void in
                        self.shadedView.hidden = true
                        self.performSegueWithIdentifier("loginCompleted", sender: nil)
                    })
                }
            }
        })
    }
    
        
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateNextButton()
    }
    
    func validateNextButton() {
        if emailTextField.text != "" {
            nextButton.enable()
        }
        else {
            nextButton.disable()
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        Flurry.logEvent("Start_Cancelled_By_User")
        dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logIn" {
            shadedView.hidden = true
            let loginViewController = segue.destinationViewController as! LogInViewController
            loginViewController.email = emailTextField.text!
        }
        else if segue.identifier == "signUp" {
            shadedView.hidden = true
            let personalDetailsViewController = segue.destinationViewController as! PersonalDetailsViewController
            personalDetailsViewController.email = emailTextField.text!
        }
    }

}
