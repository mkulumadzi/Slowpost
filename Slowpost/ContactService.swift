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
import Alamofire

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
                PersonService.searchForContactsOnSlowpost()
            })
        })
    }
    
    class func addContactToCoreData(contact: CNContact, coreDataEmailAddresses: [String]) {
        if (!contact.givenName.isEmpty || !contact.familyName.isEmpty) && contact.emailAddresses.count > 0 {
            let contactEmailAddresses = getContactEmailAddresses(contact)
            let matchEmail = Set(contactEmailAddresses).intersect(Set(coreDataEmailAddresses))
            if matchEmail.count > 0 {
                print("Found match with existing person")
                addPhoneContactToPostofficePersonRecord(contact, email: Array(matchEmail)[0])
            }
            else {
                print("Creating new person")
                createNewPersonFromContact(contact)
            }
        }
    }
    
    class func addPhoneContactToPostofficePersonRecord(contact: CNContact, email: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "primaryEmail == %@", email)
        fetchRequest.predicate = predicate
        let personMatch = CoreDataService.executeFetchRequest(dataController.moc, fetchRequest: fetchRequest)
        if personMatch != nil {
            let person = personMatch![0] as! Person
            person.contactId = contact.identifier
            dataController.save()
        }
        else {
            print("Error merging contact with Postoffice record")
        }
    }
    
    class func createNewPersonFromContact(contact: CNContact) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let person = dataController.getCoreDataObject("contactId == %@", predicateValue: contact.identifier, entityName: "Person") as! Person
        
        person.contactId = contact.identifier
        person.name = self.createFullNameFromContact(contact)
        person.origin = "Phone"
        person.nameLetter = person.getLetterFromName(person.name)
        
        self.addEmailsToNewPerson(person, contact: contact, dataController: dataController)
        
        dataController.save()
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
    
    class func addEmailsToNewPerson(person: Person, contact:CNContact, dataController: DataController) {
        let contactEmails = self.getContactEmailAddresses(contact)
        let emails = person.mutableSetValueForKey("emails")
        for email in contactEmails {
            let emailAddress = dataController.getCoreDataObject("email == %@", predicateValue: email, entityName: "EmailAddress") as! EmailAddress
            emailAddress.email = email
            emails.addObject(emailAddress)
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