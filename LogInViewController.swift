//
//  LogInViewController2.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class LogInViewController: UIViewController {
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!

    var person:Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.text = ""
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
//To do: Figure out how to reset label when editing happens; this wasn't working...
//    @IBAction func editingLogin(sender: AnyObject) {
//        println("Firing!")
//        self.warningLabel.text = ""
//    }
    
    @IBAction func LogIn(sender: AnyObject) {
        disableLogin()

        attemptLogIn( { (error, result) -> Void in
            if  error != nil {
                println(error)
            }
            else if let result: AnyObject = result {
                if result as! String == "Success" {
                    DataManager.getPeople("username=\(self.UsernameTextField.text)", completion: { (error, result) -> Void in
                        if error != nil {
                            println(error)
                        }
                        else if let personArray = result as? Array<Person> {
                            //Assume Person Array will always have only 1 entry, since username is unique... but should do a better job of handling this...
                            loggedInUser = personArray[0]
                            
                            var storyboard = UIStoryboard(name: "initial", bundle: nil)
                            var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                            self.presentViewController(controller, animated: true, completion: nil)
                            
                        }
                    })
                }
                else {
                    self.warningLabel.text = "Invalid login"
                }
            }
        })
        
    }
    
    func attemptLogIn(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let parameters = ["username": "\(UsernameTextField.text)", "password": "\(passwordTextField.text)"]
        
        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 200 {
                        completion(error: nil, result: "Success" as String!)
                    }
                    if response.statusCode == 401 {
                        completion(error: nil, result: "Failure" as String!)
                    }
                }
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    @IBAction func usernameEditingChanged(sender: AnyObject) {
        enableLogin()
    }
    
    @IBAction func passwordEditingChanged(sender: AnyObject) {
        enableLogin()
    }
    
    func disableLogin() {
        logInButton.enabled = false
        logInButton.backgroundColor = UIColor.darkGrayColor()
    }
    
    func enableLogin() {
        logInButton.enabled = true
        logInButton.backgroundColor = UIColor(red: 51/255, green: 153/255, blue: 102/255, alpha: 1.0)
    }
    
}