//
//  AddressBookService.swift
//  Slowpost
//
//  Created by Evan Waters on 7/15/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import SwiftyJSON

//var addressBook:ABAddressBook!

class AddressBookService {
    
    class func checkAuthorizationStatus(sender: UIViewController) {
        let addressBookService:AddressBookService = AddressBookService.init()
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .Denied, .Restricted:
            println("Unauthorized")
        case .Authorized:
            addressBook =  ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        case .NotDetermined:
            addressBookService.promptForAddressBookAccess(sender)
        }
    }
    
    func promptForAddressBookAccess(sender: UIViewController) {
        
        var err: Unmanaged<CFError>? = nil
        
        ABAddressBookRequestAccessWithCompletion(addressBook) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    self.displayUnauthorizedAddessBookAlert(sender)
                } else {
                    self.accessGranted()
                }
            }
        }
    }
    
    func accessGranted() {
        println("Access granted!")
        addressBook =  ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func displayUnauthorizedAddessBookAlert(sender: UIViewController) {
        let cantAccessAddressBookAlert = UIAlertController(title: "Are you sure?",
            message: "Slowpost works best when you can send it to people you know!",
            preferredStyle: .Alert)
        cantAccessAddressBookAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openSettings()
        }))
        cantAccessAddressBookAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        sender.presentViewController(cantAccessAddressBookAlert, animated: true, completion: nil)
    }
    
    func getNameFromContact(person: ABRecord) -> NSString {
        if let name = ABRecordCopyCompositeName(person)?.takeRetainedValue() as? NSString {
            return name
        }
        else {
            return ""
        }
    }
    
    func getPhoneNumbersFromContact(person: ABRecord) -> [NSString] {
        var phoneNumbers = [NSString]()
        var phones : ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
        
        for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(phones); numberIndex++) {
            let phoneUnmaganed = ABMultiValueCopyValueAtIndex(phones, numberIndex)
            
            let phoneNumber : NSString = phoneUnmaganed.takeUnretainedValue() as! NSString
            
            phoneNumbers.append(phoneNumber)
        }
        return phoneNumbers
    }
    
    func getEmailsFromContact(person: ABRecord) -> [NSString] {
        var emails = [NSString]()
        var emailRecords : ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeUnretainedValue() as ABMultiValueRef
        
        for(var numberIndex : CFIndex = 0; numberIndex < ABMultiValueGetCount(emailRecords); numberIndex++) {
            let emailUnmaganed = ABMultiValueCopyValueAtIndex(emailRecords, numberIndex)
            
            let email : NSString = emailUnmaganed.takeUnretainedValue() as! NSString
            
            emails.append(email)
        }

        return emails
    }
    
    func createDictionaryWithContactInfo(person: ABRecord) -> NSDictionary {
        
        var name = getNameFromContact(person)
        var phoneNumbers = getPhoneNumbersFromContact(person)
        var emails = getEmailsFromContact(person)
        
        var contactDict:NSDictionary = [
            "name": name,
            "phoneNumbers": phoneNumbers,
            "emails": emails
        ]
        
        return contactDict
    }
    
    func getContacts(addressBook: ABAddressBook) -> [ABRecord] {
        var addressBookContacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray as [ABRecord]
        return addressBookContacts
    }
    
    class func getContactsFromAddresssBook(addressBook: ABAddressBook) -> [NSDictionary] {
        let addressBookService:AddressBookService = AddressBookService.init()
        
        var addressBookContacts = addressBookService.getContacts(addressBook)
        var contacts = [NSDictionary]()
        
        for person in addressBookContacts {
            contacts.append(addressBookService.createDictionaryWithContactInfo(person))
        }
        
        return contacts
    }

}