//
//  LogInViewController2.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: BottomBorderUITextField!
    @IBOutlet weak var usernameTextField: BottomBorderUITextField!
    @IBOutlet weak var emailTextField: BottomBorderUITextField!
    @IBOutlet weak var phoneTextField: BottomBorderUITextField!
    @IBOutlet weak var passwordTextField: BottomBorderUITextField!
    @IBOutlet weak var signUpButton: SnailMailTextUIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        nameTextField.addBottomLayer()
        usernameTextField.addBottomLayer()
        emailTextField.addBottomLayer()
        phoneTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        
        signUpButton.layer.cornerRadius = 5
        validateSignUpButton()
        
        warningLabel.hide()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        signUpButton.disable()
        
        var personURL:String!

        LoginService.signUp(["name": "\(nameTextField.text)", "username": "\(usernameTextField.text)", "email": "\(emailTextField.text)", "phone": "\(phoneTextField.text)", "password": "\(passwordTextField.text)"], completion: { (error, result) -> Void in
            if let response = result as? [String] {
                if response[0] == "Success" {
                    personURL = response[1]
                    PersonService.getPerson(personURL, completion: { (error, result) -> Void in
                        if result != nil {
                            if let user = result as? Person {
                                loggedInUser = user
                                LoginService.saveLoginToSession(loggedInUser.id)
                                self.goToMailbox(self)
                            }
                        }
                    })
                }
                else if response[0] == "Failure" {
                    let error_message = response[1]
                    self.warningLabel.show(error_message)
                }
            }
        })
        
    }
    
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateSignUpButton()
        warningLabel.hide()
    }
    
    func validateSignUpButton() {
        if nameTextField.text != "" && usernameTextField.text != "" && emailTextField.text != "" && phoneTextField.text != "" && passwordTextField.text != "" {
            signUpButton.enable()
        }
        else {
            signUpButton.disable()
        }
    }
    
    func goToMailbox(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "initial", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
}