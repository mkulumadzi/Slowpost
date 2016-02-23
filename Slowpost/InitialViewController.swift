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

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingLabel.hidden = true
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
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func beginLoadingInitialData() {
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
    
    func getContactsIfAuthorized() {
        Flurry.logEvent("Attempting_to_fetch_contacts")
        ContactService.fetchContactsIfAuthorized()
    }


    func goToHomeScreen() {
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
    
    func registerDeviceToken() {
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
    
    @IBAction func signUpOrLogInCompleted(segue: UIStoryboardSegue) {
        print("Got here after signup or login")
    }

}
