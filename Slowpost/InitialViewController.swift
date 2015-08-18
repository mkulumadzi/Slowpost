//
//  InitialViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import AddressBook
import JWTDecode

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Initial_View_Loaded")
        
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
        if loggedInUser == nil || userToken == nil {
            if MyKeychainWrapper.myObjectForKey(kSecAttrService) as? String == "postoffice" {
                if let token = MyKeychainWrapper.myObjectForKey("v_Data") as? String {
                    if JWTDecode.expired(jwt: token) == false {
                        self.setLoggedInUserFromToken(token)
                    }
                }
            }
            else {
                Flurry.logEvent("Sending_User_To_Login_Screen")
                var storyboard = UIStoryboard(name: "login", bundle: nil)
                var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        else {
            AddressBookService.checkAuthorizationStatus(self)
            getRegisteredContactsIfAuthorized()
            getMailbox()
        }
    }
    
    func goToHomeScreen() {
        
        if deviceToken != nil {
            //Sending the device token to the PostOffice server
            registerDeviceToken()
        }
        
        getOutbox()
        
        var storyboard = UIStoryboard(name: "home", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func setLoggedInUserFromToken(token: String) {
        
        //Set user token for API requests
        userToken = token
        
        let payload = JWTDecode.payload(jwt: token)
        if let userId = payload!["id"] as? String {

            PersonService.getPerson(userId, headers: nil, completion: { (error, result) -> Void in
                if error != nil {
                    println(error)
                }
                else if let person = result as? Person {
                    Flurry.logEvent("User_Logged_In_From_Session")
                    loggedInUser = person
                    AddressBookService.checkAuthorizationStatus(self)
                    self.getRegisteredContactsIfAuthorized()
                    self.getMailbox()
                }
                else {
                    var storyboard = UIStoryboard(name: "login", bundle: nil)
                    var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            })
            
        }
        else {
            println("Token did not contain User ID")
            var storyboard = UIStoryboard(name: "login", bundle: nil)
            var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    func getMailbox() {
        
        let predicate = NSPredicate(format: "to == %@", loggedInUser.username)
        
        let coreDataMailbox = MailService.populateMailArrayFromCoreData(predicate)
        if coreDataMailbox != nil {
            mailbox = coreDataMailbox!
        }
        
        var headers:[String: String]?
        if mailbox.count > 0 {
            headers = RestService.sinceHeader(mailbox)
        }

        let myMailBoxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/mailbox"
        
        MailService.getMailCollection(myMailBoxURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                
                mailbox = MailService.updateMailCollectionFromNewMail(mailbox, newCollection: mailArray)
                mailbox = mailbox.sorted { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
                
                MailService.appendMailArrayToCoreData(mailArray)
                
                //Get all 'penpal' records whom the user has sent mail to or received mail from
                let contactsURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/contacts"
                
                PersonService.getPeopleCollection(contactsURL, headers: nil, completion: { (error, result) -> Void in
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
    
    func getOutbox() {
        
        let predicate = NSPredicate(format: "from == %@", loggedInUser.username)
        
        let coreDataOutbox = MailService.populateMailArrayFromCoreData(predicate)
        if coreDataOutbox != nil {
            outbox = coreDataOutbox!
        }
        
        var headers:[String: String]?
        if outbox.count > 0 {
            headers = RestService.sinceHeader(outbox)
        }
        
        let myOutboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/outbox"
        MailService.getMailCollection(myOutboxURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                outbox = MailService.updateMailCollectionFromNewMail(outbox, newCollection: mailArray)
                outbox = outbox.sorted { $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedDescending }
                
                MailService.appendMailArrayToCoreData(mailArray)
            }
        })
    }
    
    func getRegisteredContactsIfAuthorized() {
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .Authorized:
            
            var contacts:[NSDictionary] = AddressBookService.getContactsFromAddresssBook(addressBook)
            
            PersonService.bulkPersonSearch(contacts, completion: { (error, result) -> Void in
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
        let parameters = ["device_token": deviceToken as String]
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)"
        
        RestService.postRequest(updatePersonURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
        })
    }

}
