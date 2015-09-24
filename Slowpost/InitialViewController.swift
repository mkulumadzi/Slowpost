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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLogin()
        
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
        let token = LoginService.getTokenFromKeychain()
        if token != nil {
            LoginService.confirmTokenMatchesValidUserOnServer( { error, result -> Void in
                if result as? String == "Success" {
                    self.beginLoadingInitialData()
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
        
        MailService.updateAllData( { error, result -> Void in
            if result as? String == "Success" {
                self.getContactsIfAuthorized()
                self.goToHomeScreen()
            }
            else {
               print(error)
            }
        })
        
    }
    
    func getContactsIfAuthorized() {
        if #available(iOS 9, *) {
            ContactService.fetchContactsIfAuthorized()
        } else {
            AddressBookService.checkAuthorizationStatus(self)
            AddressBookService.getRegisteredContactsIfAuthorized()
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
        let userId = LoginService.getUserIdFromToken()
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(userId)"
        
        RestService.postRequest(updatePersonURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
        })
    }
    
    @IBAction func signUpOrLogInCompleted(segue: UIStoryboardSegue) {
    }

}
