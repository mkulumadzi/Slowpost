//
//  ContactService.swift
//  Slowpost
//
//  Created by Evan Waters on 9/24/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import Contacts
import CoreData

@available(iOS 9.0, *)
class ContactService {
    
    class func fetchContactsIfAuthorized() {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatusForEntityType(.Contacts){
        case .Authorized:
            self.fetchContacts()
        case .NotDetermined:
            store.requestAccessForEntityType(.Contacts){succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                self.fetchContacts()
            }
        default:
            return
        }
    }
    
    class func fetchContacts() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            let coreDataEmailAddresses = PersonService.getAllEmailAddresses()
            let store = CNContactStore()
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey, CNContactIdentifierKey]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            do {
                try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (contact, cursor) -> Void in
                    self.addContactToCoreData(contact, coreDataEmailAddresses: coreDataEmailAddresses)
                })
            }
            catch {
                print(error)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("Finished getting contacts")
            })
        })
    }
    
    class func addContactToCoreData(contact: CNContact, coreDataEmailAddresses: [String]) {
        if (!contact.givenName.isEmpty || !contact.familyName.isEmpty) && contact.emailAddresses.count > 0 {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let dataController = appDelegate.dataController
            let phoneContact = dataController.getCoreDataObject(contact.identifier, entityName: "PhoneContact") as! PhoneContact
            
            phoneContact.id = contact.identifier
            phoneContact.name = self.createFullNameFromContact(contact)
            
            self.addEmailsAndPostofficeId(phoneContact, contact: contact, coreDataEmailAddresses: coreDataEmailAddresses, dataController: dataController)
            
            dataController.save()
            
        }
        
    }
    
    class func createFullNameFromContact(contact: CNContact) -> String {
        var fullName = ""
        if !contact.givenName.isEmpty {
            fullName = contact.givenName
        }
        if !contact.familyName.isEmpty {
            if fullName != "" {
                fullName += " \(contact.familyName)"
            }
            else {
                fullName = contact.familyName
            }
        }
        return fullName
    }
    
    class func addEmailsAndPostofficeId(phoneContact: PhoneContact, contact:CNContact, coreDataEmailAddresses: [String], dataController: DataController) {
        let contactEmails = self.getContactEmailAddresses(contact)
        let emails = phoneContact.mutableSetValueForKey("emails")
        for email in contactEmails {
            let emailAddress = NSEntityDescription.insertNewObjectForEntityForName("EmailAddress", inManagedObjectContext: dataController.moc) as! EmailAddress
            emailAddress.email = email
            emails.addObject(emailAddress)
        }
        
        let matchEmail = Set(contactEmails).intersect(Set(coreDataEmailAddresses))
        if matchEmail.count > 0 {
            let match = Array(matchEmail)[0]
            let fetchRequest = NSFetchRequest(entityName: "Person")
            let predicate = NSPredicate(format: "email == %@", match)
            fetchRequest.predicate = predicate
            let personMatch = CoreDataService.executeFetchRequest(dataController.moc, fetchRequest: fetchRequest)
            if personMatch != nil {
                let person = personMatch![0] as! Person
                phoneContact.postofficeId = person.id
            }
        }
    }
    
    class func getContactEmailAddresses(contact: CNContact) -> [String] {
        var emailAddresses = [String]()
        for emailAddress in contact.emailAddresses {
            let email = emailAddress.value as! String
            emailAddresses.append(email)
        }
        return emailAddresses
    }
    
}