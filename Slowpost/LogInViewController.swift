//
//  LogInViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

class LogInViewController: BaseViewController, UITextFieldDelegate {
    
    var email:String!
    
    @IBOutlet weak var passwordTextField: BottomBorderUITextField!
    @IBOutlet weak var logInButton: TextUIButton!
    @IBOutlet weak var verticalSpaceToPassword: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToLogIn: NSLayoutConstraint!
    @IBOutlet weak var logInButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Login_Screen_Opened")
        passwordTextField.delegate = self
        configure()
        validateLogInButton()
    }
    
    //MARK: Setup
    
    private func configure() {
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        logInButton.layer.cornerRadius = 5
        addWarningLabel()
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
    }
    
    private func formatForiPhone4S() {
        verticalSpaceToPassword.constant = 10
        verticalSpaceToLogIn.constant = 30
        logInButtonHeight.constant = 30
        passwordTextField.font = passwordTextField.font!.fontWithSize(15.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        passwordTextField.addBottomLayer()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        LogIn(self)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    private func validateLogInButton() {
        if passwordTextField.text != "" {
            logInButton.enable()
        }
        else {
            logInButton.disable()
        }
    }
    
    //MARK: User actions
    
    @IBAction func LogIn(sender: AnyObject) {
        
        logInButton.disable()
        let parameters = ["username": "\(email)", "password": "\(passwordTextField.text!)"]

        LoginService.logIn(parameters, completion: { (error, result) -> Void in
            if let error = error {
                print(error)
                self.showLabelWithMessage(self.warningLabel, message: "Cannot connect...")
            }
            else if let result: AnyObject = result {
                if result as? String == "Success" {
                    self.performSegueWithIdentifier("loginCompleted", sender: nil)
                }
                else {
                    self.showLabelWithMessage(self.warningLabel, message: "Invalid login")
                }
            }
        })
        
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        hideItem(warningLabel)
        validateLogInButton()
    }
    
}