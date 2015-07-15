//
//  AddressBookRequestViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 7/14/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import AddressBook

class AddressBookRequestViewController: UIViewController {

    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthorizationStatus()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkAuthorizationStatus() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .Denied, .Restricted:
            println("Unauthorized")
            performSegueWithIdentifier("initialWelcomeScreen", sender: nil)
        case .Authorized:
            println("Authorized")
            performSegueWithIdentifier("initialWelcomeScreen", sender: nil)
        case .NotDetermined:
            promptForAddressBookRequestAccess()
        }
        
    }
    
    func promptForAddressBookRequestAccess() {
        var err: Unmanaged<CFError>? = nil
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    self.performSegueWithIdentifier("initialWelcomeScreen", sender: nil)
                } else {
                    self.accessGranted()
                }
            }
        }
    }
    
    func accessGranted() {
        println("Access granted!")
        performSegueWithIdentifier("initialWelcomeScreen", sender: nil)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
