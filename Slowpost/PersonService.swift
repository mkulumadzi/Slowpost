//
//  PersonService.swift
//  Slowpost
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class PersonService: PostofficeObjectService {
    
    class func appendJsonArrayToCoreData(jsonArray: [AnyObject]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let entityName = "Person"
        for item in jsonArray {
            let json = JSON(item)
            let object = dataController.getCoreDataObjectForJson(json, entityName: entityName)
            self.addOrUpdateCoreDataEntityFromJson(json, object: object)
        }
    }
    
    override class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject) {
        let person = object as! Person
        person.username = json["username"].stringValue
        person.givenName = json["given_name"].stringValue
        person.familyName = json["family_name"].stringValue
        person.primaryEmail = json["email"].stringValue
        person.origin = "Postoffice"
        person.nameLetter = person.getLetterFromName()
        
        super.addOrUpdateCoreDataEntityFromJson(json, object: person)
    }
    
    class func getAllEmailAddresses() -> [String] {
        var emailAddresses = [String]()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "origin == %@", "Postoffice")
        fetchRequest.predicate = predicate
        let fetchedResults = (try? dataController.moc.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
        if fetchedResults!.count > 0 {
            for result in fetchedResults! {
                let person = result as! Person
                if person.primaryEmail != "" { emailAddresses.append(person.primaryEmail) }
            }
        }
        return emailAddresses
    }
    
    class func searchForContactsOnSlowpost() {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            let emails = self.getEmailsForAllPhoneContacts()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if emails.count > 0 {
                    self.findMatchesAndUpdateContacts(emails)
                }
            })
        })
    }
    
    class func getEmailsForAllPhoneContacts() -> [String] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "origin == %@", "Phone")
        let people = CoreDataService.executeFetchRequest(dataController.moc, fetchRequest: fetchRequest)
        var emailArray = [String]()
        for object in people! {
            let person = object as! Person
            for item in person.emails.allObjects {
                let emailAddress = item as! EmailAddress
                emailArray.append(emailAddress.email)
            }
        }
        return emailArray
    }
    
    class func findMatchesAndUpdateContacts(emails: [String]) {
        self.findMatchesFromEmails(emails, completion: { (error, result) -> Void in
            if let dataArray = result as? [AnyObject] {
                print(dataArray)
                for item in dataArray {
                    let json = JSON(item)
                    self.updatePhoneContactWithSlowpostInfo(json)
                }
            }
            else {
                print(error)
            }
        })
    }
    
    class func findMatchesFromEmails(emails: [String], completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let parameters = ["emails": emails]
        let url = "\(PostOfficeURL)/people/find_matches"
        let headers = ["Authorization": RestService.addAuthHeader()]
        Alamofire.request(.POST, url, parameters: parameters, headers: headers, encoding: .JSON)
            .responseJSON { (response) in
                switch response.result {
                case .Success (let result):
                    if let dataArray = result as? [AnyObject] {
                        completion(error: nil, result: dataArray)
                    }
                    else {
                        completion(error: nil, result: "Unexpected result")
                    }
                case .Failure(let error):
                    completion(error: error, result: nil)
                }
        }
    }
    
    class func updatePhoneContactWithSlowpostInfo(json: JSON) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let email = json["email"].stringValue
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "ANY emails.email == %@", email)
        let person = CoreDataService.executeFetchRequest(dataController.moc, fetchRequest: fetchRequest)![0] as! Person
        person.username = json["username"].stringValue
        person.givenName = json["given_name"].stringValue
        person.familyName = json["family_name"].stringValue
        person.primaryEmail = json["email"].stringValue
        
        // Keeping this as Phone to ensure it is not confused for an actual person the user has sent or received mail to
        person.origin = "Phone"
        person.nameLetter = person.getLetterFromName()
        
        super.addOrUpdateCoreDataEntityFromJson(json, object: person)
        
    }
    

    
}