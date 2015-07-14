//
//  InitialViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData

var deviceToken:String!
var loggedInUser:Person!
var mailbox = [Mail]()
var people = [Person]()
var coreDataPeople = [NSManagedObject]()
var coreDataMail = [NSManagedObject]()

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLogin() {
        if loggedInUser == nil {
            let userId = DataManager.getUserIdFromSession()
            if userId != "" {
                self.setLoggedInUserFromUserId(userId)
            }
            else {
                var storyboard = UIStoryboard(name: "login", bundle: nil)
                var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        else {
            getMailbox()
        }
    }
    
    func goToHomeScreen() {
        
        if deviceToken != nil {
            //Sending the device token to the PostOffice server
            registerDeviceToken()
        }
        
        var storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        checkLogin()
        
    }
    
    func setLoggedInUserFromUserId(userId: String) {
        
        DataManager.getPeople("id=\(userId)", completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let personArray = result as? Array<Person> {
                
                //Assume if logged in user exists, person array will always have only 1 entry, since username is unique... but should do a better job of handling this...
                if personArray.count > 0 {
                    loggedInUser = personArray[0]
                    self.getMailbox()
                }
                // If session is stored for a user that has been deleted, need to log in again
                else {
                    var storyboard = UIStoryboard(name: "login", bundle: nil)
                    var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                    
                    self.presentViewController(controller, animated: true, completion: nil)
                }
                
            }
        })
        
    }
        
    func getMailbox() {
        
        //Initially populate mailbox by retrieving mail for the user
        DataManager.getMyMailbox( { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                mailbox = mailArray.sorted { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
                //Get all peoplle records
                DataManager.getPeople("", completion: { (error, result) -> Void in
                    if error != nil {
                        println(error)
                    }
                    else if let peopleArray = result as? Array<Person> {
                        people = peopleArray
                        self.goToHomeScreen()
                    }
                })
            }
        })
    }
    
    func registerDeviceToken() {
        let person = loggedInUser
        let parameters = ["device_token": deviceToken as String]
        
        DataManager.updatePerson(person, parameters: parameters, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
        })
    }

}
