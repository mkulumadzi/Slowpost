//
//  LogInViewController2.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class PersonalDetailsViewController: UIViewController {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    
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
    
    @IBAction func signUpComleted(sender: AnyObject) {
        
        let parameters = ["address1": "\(addressTextField.text)", "city": "\(cityTextField.text)", "state": "\(stateTextField.text)", "zip": "\(zipTextField.text)"]
        
        self.updatePerson( { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else {
                self.updateLoggedInUser()
            }
        })
    }
    
    func updatePerson(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)"
        let parameters = ["address1": "\(addressTextField.text)", "city": "\(cityTextField.text)", "state": "\(stateTextField.text)", "zip": "\(zipTextField.text)"]
        
        Alamofire.request(.POST, updatePersonURL, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 204 {
                        completion(error: nil, result: "Update succeeded")
                    }
                }
        }
        
    }
    
    func updateLoggedInUser() {
        
        let personURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)"
        
        DataManager.getPerson(personURL, completion: { (error, result) -> Void in
            if result != nil {
                if let user = result as? Person {
                    loggedInUser = user
                    self.performSegueWithIdentifier("signUpComplete", sender: nil)
                }
            }
        })
        
    }
    
}