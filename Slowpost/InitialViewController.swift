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
import SwiftyJSON

class InitialViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
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
        if loggedInUser == nil || userToken == nil {
            if MyKeychainWrapper.myObjectForKey(kSecAttrService) as? String == "postoffice" {
                if let token = MyKeychainWrapper.myObjectForKey("v_Data") as? String {
                    do {
                        let jwt = try decode(token)
                        if jwt.expired == false {
                            self.setLoggedInUserFromToken(token)
                        }
                    } catch _ {
                        print("Could not decode token")
                    }
                }
            }
            else {
                goToLoginScreen()
            }
        }
        else {
            beginLoadingInitialData()
        }
    }
    
    func setLoggedInUserFromToken(token: String) {
        print("Found token, trying to set logged in user at \(NSDate())")
        print("The token is \(token)")
        
        userToken = token
        var payload:[String : AnyObject]!
        do {
            let jwt = try decode(token)
            payload = jwt.body
        } catch _ {
            print("Could not decode token")
        }
        
        print(payload)
    
        if let userId = payload!["id"] as? String {
            
            // Trying to get LoggedInUser from core data to avoid downloading from server
            let predicate = NSPredicate(format: "id == %@", userId)
            let loggedInRecordFromCoreData = PersonService.populatePersonArrayFromCoreData(predicate, entityName: "LoggedInUser")
            
            var headers:[String: String]!
            if loggedInRecordFromCoreData.count > 0 {
                loggedInUser = loggedInRecordFromCoreData[0]
                headers = ["IF_MODIFIED_SINCE": loggedInUser.updatedAtString]
            }
            
            print("Getting person record from token id at \(NSDate())")
            print(headers)
            PersonService.getPerson(userId, headers: headers, completion: { (error, result) -> Void in
                print("The result is \(result)")
                if let person = result as? Person {
                    Flurry.logEvent("User_Logged_In_From_Session")
                    loggedInUser = person
                    self.beginLoadingInitialData()
                }
                else if let status = result as? Int {
                    if status == 304 {
                        // User already has the latest record, no need to update
                        Flurry.logEvent("User_Logged_In_From_Session")
                        self.beginLoadingInitialData()
                    }
                    else {
                        // Handles cases such as a 404 status, where the ID is not found on the server
                        self.goToLoginScreen()
                    }
                }
                else {
                    self.goToLoginScreen()
                }
            })
        }
        else {
            goToLoginScreen()
        }
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
        
        PersonService.updatePeople()
        ConversationService.updateConversations()
        MailService.updateMailbox()
        MailService.updateOutbox()
        getRegisteredContactsIfAuthorized()
        
        goToHomeScreen()
    }

    func getRegisteredContactsIfAuthorized() {
        print("Getting registered contacts at \(NSDate())")
        
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .Authorized:
            
            let contacts:[NSDictionary] = AddressBookService.getContactsFromAddresssBook(addressBook)
            
            PersonService.bulkPersonSearch(contacts, completion: { (error, result) -> Void in
                if let peopleArray = result as? Array<Person> {
                    registeredContacts = peopleArray
                }
            })
            
        default:
            print("Not authorized")
        }
    }
    
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
