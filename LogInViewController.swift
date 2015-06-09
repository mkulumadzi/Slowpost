//
//  LogInViewController2.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

var people = [Person]()

class LogInViewController: UIViewController {
    
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var person:Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //This is something that should be optimized...
//        DataManager.getAllPeopleWithSuccess{ (peopleData) -> Void in
//            let json = JSON(data: peopleData)
//            
//            for personDict in json.arrayValue {
//                var id: String = personDict["_id"]["$oid"].stringValue
//                var username: String = personDict["username"].stringValue
//                var name: String = personDict["name"].stringValue
//                
//                var person = Person(id: id, username: username, name: name, address1: nil, city: nil, state: nil, zip: nil)
//                
//                people.append(person)
//            }
//
//        }
        
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
                    println("Log In Succeeded")
                    DataManager.getPeople("username=\(self.UsernameTextField.text)", completion: { (error, result) -> Void in
                        if error != nil {
                            println(error)
                        }
                        else if result != nil {
                            println(result)
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
    
//    func getLoggedInPerson {
//        self.getPerson(personURL, completion: { (error, result) -> Void in
//            if result != nil {
//                if let user = result as? Person {
//                    loggedInUser = user
//                    self.performSegueWithIdentifier("signUpSuccessful", sender: nil)
//                }
//            }
//        })
//    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    

    
}