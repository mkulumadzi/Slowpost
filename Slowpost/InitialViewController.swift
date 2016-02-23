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

class InitialViewController: BaseViewController {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        print("Initial view loaded at \(NSDate())")
        Flurry.logEvent("Initial_View_Loaded")
        
    }
    
    //MARK: Initial setup

    func configure() {
        loadingLabel.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        checkLogin()
    }
    
    //MARK: Private
    
    private func checkLogin() {
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
    
    private func goToLoginScreen() {
        Flurry.logEvent("Sending_User_To_Login_Screen")
        let storyboard = UIStoryboard(name: "login", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") 
        presentViewController(controller, animated: true, completion: nil)
    }
    
    private func beginLoadingInitialData() {
        let interval = NSTimeInterval(1.0)
        iconImage.image = UIImage.animatedImageNamed("turtleAnimation", duration: interval)
        loadingLabel.hidden = false
        
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
    
    private func getContactsIfAuthorized() {
        Flurry.logEvent("Attempting_to_fetch_contacts")
        ContactService.fetchContactsIfAuthorized()
    }


    private func goToHomeScreen() {
        loadingLabel.hidden = true
        iconImage.image = UIImage(named: "turtleAnimation")
        
        if deviceToken != nil {
            registerDeviceToken()
        }
        
        Flurry.endTimedEvent("Initial_Data_Loading_Began", withParameters: nil)
        let storyboard = UIStoryboard(name: "home", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") 
        presentViewController(controller, animated: false, completion: nil)
    }
    
    private func registerDeviceToken() {
        let parameters = ["device_token": deviceToken as String]
        let userId = LoginService.getUserIdFromToken()
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(userId)"
        print("Registering device token: \(deviceToken)")
        
        RestService.postRequest(updatePersonURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            if let error = error {
                print(error)
            }
        })
    }
    
    //MARK: Segues
    
    @IBAction func signUpOrLogInCompleted(segue: UIStoryboardSegue) {
        print("Got here after signup or login")
    }

}
