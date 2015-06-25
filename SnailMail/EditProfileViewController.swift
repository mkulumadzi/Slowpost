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

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var address1Field: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var saveButton: SnailMailTextUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.text = loggedInUser.name
        emailLabel.text = loggedInUser.username
        address1Field.text = loggedInUser.address1
        cityField.text = loggedInUser.city
        stateField.text = loggedInUser.state
        zipField.text = loggedInUser.zip
        

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
        let parameters = ["name": "\(nameField.text)", "address1": "\(address1Field.text)", "city": "\(cityField.text)", "state": "\(stateField.text)", "zip": "\(zipField.text)"]
        
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
