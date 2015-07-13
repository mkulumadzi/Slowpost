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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: SnailMailTextUIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                                self.performSegueWithIdentifier("signUpComplete", sender: nil)
                            }
                        }
                    })
                }
                else if response[1] == "Forbidden" {
                    self.warningLabel.show("Username already registered")
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
                    if response.statusCode == 403 {
                        completion(error: nil, result: ["Failure", "Forbidden"])
                    }
                }
        }
        
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        signUpButton.enable()
        warningLabel.hide()
    }
    
}