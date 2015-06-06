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
    
    var person:Person!
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signUpSuccessful" {
            signUp()
        }
    }
    
    
    func signUp() {
        
        let newPersonEndpoint = "\(PostOfficeURL)person/new"
        let parameters = ["name": "\(nameTextField.text)", "username": "\(usernameTextField.text)"]
        
        Alamofire.request(.POST, newPersonEndpoint, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 201 {
                        println("You've registered!")
                        var personURL:String = response.allHeaderFields["Location"] as! String
                        println(personURL)
                    }
                }
            }
    }
    
//    func logInAfterSignup(requestURL: String) -> Person {
//        
//    }
    
//    @IBAction func LogIn(sender: AnyObject) {
//        for user in people {
//            if user.username == UsernameTextField.text {
//                loggedInUser = user
//                self.dismissViewControllerAnimated(true, completion: nil)
//            }
//        }
//    }
    
    
    
    
}