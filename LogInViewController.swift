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

    var person:Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func LogIn(sender: AnyObject) {

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
                            
                            var storyboard = UIStoryboard(name: "Main", bundle: nil)
                            var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                            self.presentViewController(controller, animated: true, completion: nil)
                            
                        }
                    })
                }
                else {
                    println("Log in failed")
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
    
    

    
}