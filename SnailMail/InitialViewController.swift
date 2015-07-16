//
//  InitialViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import AddressBook

var deviceToken:String!
var loggedInUser:Person!
var mailbox = [Mail]()
var people = [Person]()
var penpals = [Person]()
var registeredContacts = [Person]()
var coreDataPeople = [NSManagedObject]()
var coreDataMail = [NSManagedObject]()

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        checkLogin()
        
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
            AddressBookHelper.checkAuthorizationStatus(self)
            getRegisteredContactsIfAuthorized()
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
    
    func setLoggedInUserFromUserId(userId: String) {
        
        DataManager.getPeople("id=\(userId)", completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let personArray = result as? Array<Person> {
                
                //Assume if logged in user exists, person array will always have only 1 entry, since username is unique... but should do a better job of handling this...
                if personArray.count > 0 {
                    loggedInUser = personArray[0]
                    AddressBookHelper.checkAuthorizationStatus(self)
                    self.getRegisteredContactsIfAuthorized()
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
                
                //Get all 'penpal' records whom the user has sent mail to or received mail from
                DataManager.getPenpals(loggedInUser.id, completion: { (error, result) -> Void in
                    if error != nil {
                        println(error)
                    }
                    else if let peopleArray = result as? Array<Person> {
                        penpals = peopleArray
                        self.goToHomeScreen()
                    }
                })
            }
        })
    }
    
    func getRegisteredContactsIfAuthorized() {
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .Authorized:
            
            var contacts:[NSDictionary] = AddressBookHelper.getContactsFromAddresssBook(addressBook)
            
            DataManager.bulkPersonSearch(contacts, completion: { (error, result) -> Void in
                if error != nil {
                    println(error)
                }
                else if let peopleArray = result as? Array<Person> {
                    registeredContacts = peopleArray
                }
            })
            
        default:
            println("Not authorized")
        }
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
