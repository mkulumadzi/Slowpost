//
//  RegisterViewController.swift
//  Slowpost
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
    @IBOutlet weak var signUpButton: TextUIButton!
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
        let newPersonURL = "\(PostOfficeURL)person/new"
        var parameters = ["name": "\(nameTextField.text)", "username": "\(usernameTextField.text)", "email": "\(emailTextField.text)", "phone": "\(phoneTextField.text)", "password": "\(passwordTextField.text)"]
        
        RestService.postRequest(newPersonURL, parameters: parameters, completion: { (error, result) -> Void in
            if let response = result as? [AnyObject] {
                if response[0] as? Int == 201 {
                    if let location = response[1] as? String {
                        var personId:String = PersonService.parsePersonURLForId(location)
                        PersonService.getPerson(personId, headers: nil, completion: { (error, result) -> Void in
                            if error != nil {
                                println(error)
                            }
                            else if let person = result as? Person {
                                loggedInUser = person
                                LoginService.saveLoginToSession(loggedInUser.id)
                                self.goToMailbox(self)
                            }
                            else {
                                println("Unexpected sign up result.")
                            }
                        })
                    }
                }
                else if let error_message = response[1] as? String {
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
        if nameTextField.text != "" && usernameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
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