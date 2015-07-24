//
//  EditProfileViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/15/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class EditProfileViewController: UIViewController {

    @IBOutlet weak var nameField: BottomBorderUITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: BottomBorderUITextField!
    @IBOutlet weak var address1Field: BottomBorderUITextField!
    @IBOutlet weak var cityField: BottomBorderUITextField!
    @IBOutlet weak var stateField: BottomBorderUITextField!
    @IBOutlet weak var zipField: BottomBorderUITextField!
    @IBOutlet weak var saveButton: SnailMailTextUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.text = loggedInUser.name
        usernameField.text = loggedInUser.username
        emailField.text = loggedInUser.email
        phoneField.text = loggedInUser.phone
        address1Field.text = loggedInUser.address1
        cityField.text = loggedInUser.city
        stateField.text = loggedInUser.state
        zipField.text = loggedInUser.zip
        
        nameField.addBottomLayer()
        phoneField.addBottomLayer()
        address1Field.addBottomLayer()
        cityField.addBottomLayer()
        stateField.addBottomLayer()
        zipField.addBottomLayer()
        
        saveButton.layer.cornerRadius = 5
        
        usernameField.enabled = false
        emailField.enabled = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    @IBAction func saveEditedInfo(sender: AnyObject) {
        saveButton.disable()
        
        self.updatePerson( { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else {
                self.updateLoggedInUser()
            }
        })
    }
    
    //To Do: Abstract this into the DataManager class
    func updatePerson(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)"
        let parameters = ["name": "\(nameField.text)", "phone": "\(phoneField.text)", "address1": "\(address1Field.text)", "city": "\(cityField.text)", "state": "\(stateField.text)", "zip": "\(zipField.text)"]
        
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
    
    //To Do: Abstract this into the DataManager class
    func updateLoggedInUser() {
        
        let personURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)"
        
        DataManager.getPerson(personURL, completion: { (error, result) -> Void in
            if result != nil {
                if let user = result as? Person {
                    loggedInUser = user
                    
                    var storyboard = UIStoryboard(name: "profile", bundle: nil)
                    var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                    
                }
            }
        })
        
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        saveButton.enable()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
}
