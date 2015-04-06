//
//  LogInViewController2.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

var people = [Person]()

class LogInViewController: UIViewController {
    
    @IBOutlet weak var UsernameTextField: UITextField!

    var person:Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.getAllPeopleWithSuccess{ (peopleData) -> Void in
            let json = JSON(data: peopleData)
            
            for personDict in json.arrayValue {
                var id: String = personDict["_id"]["$oid"].stringValue
                var username: String = personDict["username"].stringValue
                var name: String = personDict["name"].stringValue
                
                var person = Person(id: id, username: username, name: name, address1: nil, city: nil, state: nil, zip: nil)
                
                people.append(person)
            }

        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func LogIn(sender: AnyObject) {
        for user in people {
            if user.username == UsernameTextField.text {
                loggedInUser = user
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    
}