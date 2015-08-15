//
//  LogInViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class LogInViewController: UIViewController {
    
    @IBOutlet weak var UsernameTextField: BottomBorderUITextField!
    @IBOutlet weak var passwordTextField: BottomBorderUITextField!
    @IBOutlet weak var logInButton: TextUIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    @IBOutlet weak var verticalSpaceToUsername: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToPassword: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToLogIn: NSLayoutConstraint!
    @IBOutlet weak var logInButtonHeight: NSLayoutConstraint!
    
    var person:Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Login_Screen_Opened")
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UsernameTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        
        logInButton.layer.cornerRadius = 5
        
        validateLogInButton()
        warningLabel.hide()
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        verticalSpaceToUsername.constant = 50
        verticalSpaceToPassword.constant = 10
        verticalSpaceToLogIn.constant = 30
        logInButtonHeight.constant = 30
        
        UsernameTextField.font = UsernameTextField.font.fontWithSize(15.0)
        passwordTextField.font = passwordTextField.font.fontWithSize(15.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LogIn(sender: AnyObject) {
        logInButton.disable()

        attemptLogIn( { (error, result) -> Void in
            if  error != nil {
                println(error)
            }
            else if let result: AnyObject = result {
                if let person:Person = result as? Person {
                    LoginService.saveLoginToSession(person.id)
                    loggedInUser = person
                    
                    var storyboard = UIStoryboard(name: "initial", bundle: nil)
                    var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                }
                else {
                    self.warningLabel.show("Invalid login")
                }
            }
        })
        
    }
    
    func attemptLogIn(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        //Sending field as 'username'; postoffice server checks for username and email match
        let parameters = ["username": "\(UsernameTextField.text)", "password": "\(passwordTextField.text)"]
        
        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 401 {
                        completion(error: nil, result: response.statusCode)
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let response = JSON as? NSDictionary {
                    var person:Person! = PersonService.createPersonFromJson(response)
                    completion(error: nil, result: person)
                }
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        warningLabel.hide()
        validateLogInButton()
    }
    
    func validateLogInButton() {
        if UsernameTextField.text != "" && passwordTextField.text != "" {
            logInButton.enable()
        }
        else {
            logInButton.disable()
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        Flurry.logEvent("Login_Cancelled_By_User")
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
}