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
            let userId = LoginService.getUserIdFromSession()
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
            AddressBookService.checkAuthorizationStatus(self)
            getRegisteredContactsIfAuthorized()
            
            println("Getting mailbox")
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
    
    func setLoggedInUserFromUserId(userId: String) {
        
        PersonService.getPerson(userId, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let person = result as? Person {
                loggedInUser = person
                AddressBookService.checkAuthorizationStatus(self)
                self.getRegisteredContactsIfAuthorized()
                
                println("Getting mailbox")
                self.getMailbox()
            }
            else {
                var storyboard = UIStoryboard(name: "login", bundle: nil)
                var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        })
    }
    
    func getMailbox() {
        
        let coreDataMailbox = MailService.populateMailArrayFromCoreData("Mail")
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
                
                MailService.appendMailArrayToCoreData(mailArray, entityName: "Mail")
                
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
        let myOutboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/outbox"
        MailService.getMailCollection(myOutboxURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                outbox = mailArray.sorted { $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending }
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
        
        RestService.postRequest(updatePersonURL, parameters: parameters, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
        })
    }

}
