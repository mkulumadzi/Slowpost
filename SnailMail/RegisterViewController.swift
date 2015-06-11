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
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        var personURL:String!

        signUp( { (error, result) -> Void in
            if result != nil {
                personURL = result as! String
                DataManager.getPerson(personURL, completion: { (error, result) -> Void in
                    if result != nil {
                        if let user = result as? Person {
                            loggedInUser = user
                            self.performSegueWithIdentifier("signUpSuccessful", sender: nil)
                        }
                    }
                })
            }
        })
        
    }
    
    func signUp(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let newPersonEndpoint = "\(PostOfficeURL)person/new"
        let parameters = ["name": "\(nameTextField.text)", "username": "\(usernameTextField.text)", "password": "\(passwordTextField.text)"]
        
        Alamofire.request(.POST, newPersonEndpoint, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 201 {
                        completion(error: nil, result: response.allHeaderFields["Location"] as! String)
                    }
                }
        }
        
    }
    
}