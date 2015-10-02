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
    
//    class func updatePeople() {
//        print("Updating people at \(NSDate())")
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let dataController = appDelegate.dataController
//        let userId = LoginService.getUserIdFromToken()
//        let peopleURL = "\(PostOfficeURL)person/id/\(userId)/contacts"
//        let headers = dataController.getIfModifiedSinceHeaderForEntity("Person")
//        
//        RestService.getRequest(peopleURL, headers: headers, completion: { (error, result) -> Void in
//            if let jsonArray = result as? [AnyObject] {
//                self.appendJsonArrayToCoreData(jsonArray)
//            }
//        })
//    }
    
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
        person.name = json["name"].stringValue
        person.primaryEmail = json["email"].stringValue
        person.phone = json["phone"].stringValue
        person.address1 = json["address1"].stringValue
        person.city = json["city"].stringValue
        person.state = json["state"].stringValue
        person.zip = json["zip"].stringValue
        person.origin = "Postoffice"
        person.nameLetter = person.getLetterFromName(json["name"].stringValue)
        
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
    

    
}