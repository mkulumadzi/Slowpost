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
    
    var addressBook:ABAddressBook!
    var addressBookContacts = [ABRecord]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthorizationStatus()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getContacts() {
        addressBookContacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray as [ABRecord]
    }
    
    func checkAuthorizationStatus() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .Denied, .Restricted:
            println("Unauthorized")
        case .Authorized:
            addressBook =  ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            getContacts()
            println("Authorized")
        case .NotDetermined:
            promptForAddressBookRequestAccess()
        }
        
    }
    
    func promptForAddressBookRequestAccess() {
        
        var err: Unmanaged<CFError>? = nil
        
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    self.displayUnauthorizedAddessBookAlert()
                } else {
                    self.accessGranted()
                }
            }
        }
    }
    
    func accessGranted() {
        println("Access granted!")
        addressBook =  ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        getContacts()
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func displayUnauthorizedAddessBookAlert() {
        let cantAccessAddressBookAlert = UIAlertController(title: "No Address Book Access",
            message: "You have not enabled address book access.",
            preferredStyle: .Alert)
        cantAccessAddressBookAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openSettings()
        }))
        cantAccessAddressBookAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantAccessAddressBookAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("initialWelcomeScreen", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "initialWelcomeScreen" {
            if addressBookContacts.count > 0 {
                for person in addressBookContacts {
                    println(ABRecordCopyCompositeName(person).takeRetainedValue())
                    
                    let firstName:String = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
                    let lastName:String = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue() as! String
                    
                    println(firstName)
                    println(lastName)
                    
                    var phones : ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
                        
                    for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(phones); numberIndex++) {
                        let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
                        
                        let phoneNumber : NSString = phoneUnmaganed.takeUnretainedValue() as! NSString
                        println(phoneNumber)
                    }
                    
                    var emails : ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
                    
                    for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(emails); numberIndex++) {
                        let emailUnmaganed = ABMultiValueCopyValueAtIndex(emails, numberIndex)
                        
                        let email : NSString = emailUnmaganed.takeUnretainedValue() as! NSString
                        println(email)
                    }
                    
                }
            }
        }
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
