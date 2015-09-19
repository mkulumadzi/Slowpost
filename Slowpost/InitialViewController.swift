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
import SwiftyJSON

class InitialViewController: UIViewController {

    var managedContext:NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedContext = CoreDataService.initializeManagedContext()
        loggedInUser = LoginService.getLoggedInUser(managedContext)
        
        print("Initial view loaded at \(NSDate())")
        Flurry.logEvent("Initial_View_Loaded")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        print("Checking login at \(NSDate())")
        if loggedInUser == nil {
            let token = LoginService.getTokenFromKeychain()
            if token != nil {
                setLoggedInUserFromToken(token!)
            }
            else {
                goToLoginScreen()
            }
        }
        else {
            goToLoginScreen()
        }
    }
    
    func setLoggedInUserFromToken(token: String) {
        print("Found token, trying to set logged in user at \(NSDate())")
        LoginService.decodeTokenAndAttemptLogin(token, managedContext: managedContext, completion: { (error, result) -> Void in
            if result as? String == "Success" {
                self.beginLoadingInitialData()
            }
            else {
                self.goToLoginScreen()
            }
        })
    }
    
    func goToLoginScreen() {
        Flurry.logEvent("Sending_User_To_Login_Screen")
        let storyboard = UIStoryboard(name: "login", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") 
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func beginLoadingInitialData() {
        print("Beginning to load initial data at \(NSDate())")
        Flurry.logEvent("Initial_Data_Loading_Began", timed: true)
        
        AddressBookService.checkAuthorizationStatus(self)
        PersonService.updatePeople(managedContext)
        ConversationService.updateConversations(managedContext)
        MailService.updateMailbox(managedContext)
        MailService.updateOutbox(managedContext)
//        getRegisteredContactsIfAuthorized()
        
        goToHomeScreen()
    }

//    func getRegisteredContactsIfAuthorized() {
//        print("Getting registered contacts at \(NSDate())")
//        
//        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
//        switch authorizationStatus {
//        case .Authorized:
//            
//            let contacts:[NSDictionary] = AddressBookService.getContactsFromAddresssBook(addressBook)
//            
//            PersonService.bulkPersonSearch(contacts, completion: { (error, result) -> Void in
//                if let peopleArray = result as? Array<Person> {
//                    registeredContacts = peopleArray
//                }
//            })
//            
//        default:
//            print("Not authorized")
//        }
//    }
    
    func goToHomeScreen() {
        
        if deviceToken != nil {
            registerDeviceToken()
        }
        
        Flurry.endTimedEvent("Initial_Data_Loading_Began", withParameters: nil)
        let storyboard = UIStoryboard(name: "home", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") 
        self.presentViewController(controller, animated: false, completion: nil)
    }
    
    func registerDeviceToken() {
        let parameters = ["device_token": deviceToken as String]
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)"
        
        RestService.postRequest(updatePersonURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
        })
    }
    
    @IBAction func signUpOrLogInCompleted(segue: UIStoryboardSegue) {
    }

}
