//
//  EmailEntryViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 2/25/16.
//  Copyright © 2016 Evan Waters. All rights reserved.
//

import UIKit

class EmailEntryViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    var loginView:FBSDKLoginButton!
    
    @IBOutlet weak var emailTextField: BottomBorderUITextField!
    @IBOutlet weak var nextButton: TextUIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: Setup
    
    private func configure() {
        nextButton.setTintedImage("chevron-right", tintColor: UIColor.whiteColor())
        nextButton.layer.cornerRadius = 20
        emailTextField.delegate = self
        
        logOutOfFacebookIfNecessary()
        addFacebookLoginButton()
        validateNextButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        emailTextField.addWhiteBottomLayer()
    }
    
    private func addFacebookLoginButton() {
        loginView = FBSDKLoginButton()
        loginView.layer.cornerRadius = 5
        view.addSubview(loginView)
        pinItemToBottomWithOptions(loginView, toItem: view, leading: 30.0, trailing: -30.0, bottom: 0.0, height: 40.0)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
        
    }
    
    private func validateNextButton() {
        if emailTextField.text != "" {
            nextButton.enable()
        }
        else {
            nextButton.disable()
        }
    }
    

    
    //MARK: User actions
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateNextButton()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let error = error {
            print(error)
        }
        else {
            getUserInfoFromFacebook()
        }
    }
    
    func getUserInfoFromFacebook() {
//        shadedView.hidden = false
//        view.bringSubviewToFront(shadedView)
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if let error = error {
                print(error)
//                self.shadedView.hidden = true
            }
            else {
                self.completeSignupWithFacebookResult(result)
            }
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    //MARK: Private

    private func logOutOfFacebookIfNecessary() {
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    private func completeSignupWithFacebookResult(result: AnyObject) {
        let email = result.valueForKey("email") as! String
        let params = ["email": email]
        LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if let error = error {
//                self.shadedView.hidden = true
                print(error)
            }
            else {
                let availability = result!["email"].stringValue
                if availability == "available" {
//                    self.shadedView.hidden = true
                    self.performSegueWithIdentifier("chooseUsername", sender: nil)
                }
                else {
                    LoginService.logInWithFacebook({ (error, result) -> Void in
//                        self.shadedView.hidden = true
                        self.performSegueWithIdentifier("loginCompleted", sender: nil)
                    })
                }
            }
        })
    }



}
