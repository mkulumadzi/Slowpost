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
    
    
//    bottomLine.frame = CGRectMake(0.0, myTextField.frame.height - 1, myTextField.frame.width, 1.0)
//    bottomLine.backgroundColor = UIColor.whiteColor().CGColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.addBottomLayer()
        usernameTextField.addBottomLayer()
        emailTextField.addBottomLayer()
        phoneTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        
        signUpButton.layer.cornerRadius = 5
        validateSignUpButton()
        
        warningLabel.hide()
        
    }
    
//    override func viewDidLayoutSubviews() {
//        nameTextField.addBottomLayer()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        signUpButton.disable()
        
        var personURL:String!

        signUp( { (error, result) -> Void in
            if let response = result as? [String] {
                if response[0] == "Success" {
                    personURL = response[1]
                    DataManager.getPerson(personURL, completion: { (error, result) -> Void in
                        if result != nil {
                            if let user = result as? Person {
                                loggedInUser = user
                                DataManager.saveLoginToSession(loggedInUser.id)
                                self.performSegueWithIdentifier("signUpComplete", sender: nil)
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
    
    func signUp(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let newPersonEndpoint = "\(PostOfficeURL)person/new"
        let parameters = ["name": "\(nameTextField.text)", "username": "\(usernameTextField.text)", "email": "\(emailTextField.text)", "phone": "\(phoneTextField.text)", "password": "\(passwordTextField.text)"]
        
        Alamofire.request(.POST, newPersonEndpoint, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 201 {
                        completion(error: nil, result: ["Success", response.allHeaderFields["Location"] as! String])
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let response_body = JSON as? NSDictionary {
                    if let error_message = response_body["message"] as? String {
                        completion(error: nil, result: ["Failure", error_message])
                    }
                    else {
                        println("No error message")
                    }
                }
            }
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
    
}