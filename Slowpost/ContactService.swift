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
        Flurry.logEvent("Fetching_Contacts", timed: true)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let coreDataEmailAddresses = PersonService.getAllEmailAddresses()
        let store = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey, CNContactIdentifierKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (contact, cursor) -> Void in
                self.addContactToCoreData(contact, coreDataEmailAddresses: coreDataEmailAddresses, dataController: dataController)
            })
        }
        catch {
            print(error)
        }
        dataController.save()
        PersonService.searchForContactsOnSlowpost()
        Flurry.endTimedEvent("Fetching_Contacts", withParameters: nil)
    }
    
    class func addContactToCoreData(contact: CNContact, coreDataEmailAddresses: [String], dataController: DataController) {
        if (!contact.givenName.isEmpty || !contact.familyName.isEmpty) && contact.emailAddresses.count > 0 {
            let contactEmailAddresses = getContactEmailAddresses(contact)
            let matchEmail = Set(contactEmailAddresses).intersect(Set(coreDataEmailAddresses))
            if matchEmail.count > 0 {
                print("Found match with existing person")
                addPhoneContactToPostofficePersonRecord(contact, email: Array(matchEmail)[0], dataController: dataController)
            }
            else {
                createNewPersonFromContact(contact, dataController: dataController)
            }
        }
    }
    
    
    
    class func addPhoneContactToPostofficePersonRecord(contact: CNContact, email: String, dataController: DataController) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let dataController = appDelegate.dataController
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "primaryEmail == %@", email)
        fetchRequest.predicate = predicate
        let personMatch = CoreDataService.executeFetchRequest(dataController.moc, fetchRequest: fetchRequest)
        if personMatch != nil {
            let person = personMatch![0] as! Person
            person.contactId = contact.identifier
//            dataController.save()
        }
        else {
            print("Error merging contact with Postoffice record")
        }
    }
    
    class func createNewPersonFromContact(contact: CNContact, dataController: DataController) {
        if personNeedsUpdating(contact) == true {
            let person = dataController.getCoreDataObject("contactId == %@", predicateValue: contact.identifier, entityName: "Person") as! Person
            person.contactId = contact.identifier
            if !contact.givenName.isEmpty {
                person.givenName = contact.givenName
            }
            else {
                person.givenName = ""
            }
            if !contact.familyName.isEmpty {
                person.familyName = contact.familyName
            }
            else {
                person.familyName = ""
            }
            person.origin = "Phone"
            person.nameLetter = person.getLetterFromName()
            self.addEmailsToNewPerson(person, contact: contact, dataController: dataController)
//            dataController.save()
        }
    }
    
    class func personNeedsUpdating(contact: CNContact) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "contactId == %@", contact.identifier)
        let objects = dataController.executeFetchRequest(fetchRequest)!
        if objects.count == 0 {
            return true
        }
        else {
            return false
        }
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