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

class PersonService {
    
    class func createPersonFromJson(jsonEntry: JSON) -> Person {
        
        let id = jsonEntry["_id"]["$oid"].stringValue
        let username = jsonEntry["username"].stringValue
        let email = jsonEntry["email"].stringValue
        let name = jsonEntry["name"].stringValue
        let phone = jsonEntry["phone"].stringValue
        let address1 = jsonEntry["address1"].stringValue
        let city = jsonEntry["city"].stringValue
        let state = jsonEntry["state"].stringValue
        let zip = jsonEntry["zip"].stringValue
        
        let updatedString = jsonEntry["updated_at"].stringValue
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry["created_at"].stringValue
        let createdAt = NSDate(dateString: createdString)
        
        let newPerson = Person(id: id, username: username, email: email, name: name, phone: phone, address1: address1, city: city, state: state, zip: zip, updatedAt: updatedAt, updatedAtString: updatedString, createdAt: createdAt)
        
        return newPerson
    }
    
    class func populatePersonArrayFromCoreData(predicate: NSPredicate, entityName: String) -> [Person] {
        
        var personArray = [Person]()
        
        let personCoreData = CoreDataService.getObjectsFromCoreData(entityName, predicate: predicate)
        
        for nsManagedObject in personCoreData {
            personArray.append(self.createPersonFromCoreData(nsManagedObject))
        }
        
        return personArray
    }
    
    class func createPersonFromCoreData(object: NSManagedObject) -> Person {
        let id = object.valueForKey("id") as! String
        let username = object.valueForKey("username") as! String
        let name = object.valueForKey("name") as? String
        let email = object.valueForKey("email") as? String
        let phone = object.valueForKey("phone") as? String
        let address1 = object.valueForKey("address1") as? String
        let city = object.valueForKey("city") as? String
        let state = object.valueForKey("state") as? String
        let zip = object.valueForKey("zip") as? String
        let updatedAt = object.valueForKey("updatedAt") as! NSDate
        let updatedAtString = object.valueForKey("updatedAtString") as! String
        let createdAt = object.valueForKey("createdAt") as! NSDate
        
        let newPerson = Person(id: id, username: username, email: email, name: name, phone: phone, address1: address1, city: city, state: state, zip: zip, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
        
        return newPerson
    }
    
    class func appendPeopleArrayToCoreData(personArray: [Person]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        for person in personArray {
            let predicate = NSPredicate(format: "id == %@", person.id)
            let object = CoreDataService.getExistingEntityOrReturnNewEntity("Person", managedContext: managedContext, predicate: predicate)
            self.saveOrUpdatePersonInCoreData(person, object: object, managedContext: managedContext)
        }
    }
    
    class func saveOrUpdatePersonInCoreData(person: Person, object: NSManagedObject, managedContext: NSManagedObjectContext) {
        
        object.setValue(person.id, forKey: "id")
        object.setValue(person.username, forKey: "username")
        object.setValue(person.name, forKey: "name")
        object.setValue(person.email, forKey: "email")
        object.setValue(person.phone, forKey: "phone")
        object.setValue(person.address1, forKey: "address1")
        object.setValue(person.city, forKey: "city")
        object.setValue(person.state, forKey: "state")
        object.setValue(person.zip, forKey: "zip")
        object.setValue(person.updatedAt, forKey: "updatedAt")
        object.setValue(person.updatedAtString, forKey: "updatedAtString")
        object.setValue(person.createdAt, forKey: "createdAt")
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Error saving person \(error), \(error?.userInfo)")
        }
        
    }
    
    class func updateLoggedInUserInCoreData(person: Person) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let predicate = NSPredicate(format: "id == %@", person.id)
        
        let object = CoreDataService.getExistingEntityOrReturnNewEntity("LoggedInUser", managedContext: managedContext, predicate: predicate)
        self.saveOrUpdatePersonInCoreData(person, object: object, managedContext: managedContext)
    }
    
    class func getPeopleObjectsFromCoreData() -> [NSManagedObject] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var fetchedResults:[NSManagedObject]?
        do {
            let fetchRequest = NSFetchRequest(entityName: "Person")
            try fetchedResults = managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        }
        catch {
            print("Error getting fetc results")
        }
        
        return fetchedResults!
    }
    
    class func getPerson(personId: String, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let personURL = "\(PostOfficeURL)/person/id/\(personId)"
        RestService.getRequest(personURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
                completion(error: error, result: nil)
            }
            else {
                if let status = result as? Int {
                    completion(error: nil, result: status)
                }
                else {
                    let json = JSON(result!)
                    let person:Person = self.createPersonFromJson(json)
                    completion(error: nil, result: person)
                }
            }
        })
        
    }
    
    class func getPeopleCollection(collectionURL: String, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        RestService.getRequest(collectionURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
                completion(error: error, result: nil)
            }
            else {
                if let jsonArray = result as? [AnyObject] {
                    var person_array = [Person]()
                    for jsonEntry in jsonArray {
                        let json = JSON(jsonEntry)
                        person_array.append(self.createPersonFromJson(json))
                    }
                    completion(error: nil, result: person_array)
                }
                else {
                    completion(error: nil, result: "Unexpected result when getting people collection")
                }
            }
        })
    }
    
    class func updatePeopleCollectionFromNewPeople(existingCollection: [Person], newCollection: [Person]) -> [Person] {
        
        //Creating a mutable collection of people from the existing collection
        var updatedCollection:[Person] = existingCollection
        
        //Update existing people
        for person in newCollection {
            if updatedCollection.filter({$0.id == person.id}).count > 0 {
                let existingPerson:Person = updatedCollection.filter({$0.id == person.id}).first!
                let existingIndex:Int = updatedCollection.indexOf(existingPerson)!
                updatedCollection[existingIndex] = person
            }
                // Append new people
            else {
                updatedCollection.append(person)
            }
        }
        
        return updatedCollection
        
    }
    
    class func updateContactsAndAppendPeopleToCache(peopleArray: [Person]) {
        penpals = self.updatePeopleCollectionFromNewPeople(penpals, newCollection: peopleArray)
        self.appendPeopleArrayToCoreData(peopleArray)
    }
    
    
    //Bulk search of people based on a users' contact info
    class func bulkPersonSearch(parameters: [NSDictionary], completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        
        let bulkPersonSearchURL = NSURL.init(string: "\(PostOfficeURL)/people/bulk_search")
        
        let request = NSMutableURLRequest(URL: bulkPersonSearchURL!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        var error: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch let error1 as NSError {
            error = error1
            request.HTTPBody = nil
        }
        
        Alamofire.request(request)
            .responseJSON { (_, response, result) in
            switch result {
            case .Success (let data):
                if response!.statusCode == 404 {
                    completion(error: error, result: response!.statusCode)
                }
                else {
                    if let jsonArray = data as? [AnyObject] {
                        var people_array = [Person]()
                        for jsonEntry in jsonArray {
                            let json = JSON(jsonEntry)
                            people_array.append(self.createPersonFromJson(json))
                        }
                        completion(error: nil, result: people_array)
                    }
                    else {
                        completion(error: nil, result: "Unexpected result when doing bulk search")
                    }
                }
            case .Failure(_, let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    class func parsePersonURLForId(personURL:String) -> String {
        let personURLSplit:[String] = personURL.characters.split {$0 == "/"}.map { String($0) }
        let personId:String = personURLSplit.last
        return personId
    }
    
    class func loadPenpals() {
        print("Getting all penpals at \(NSDate())")
        //Get all 'penpal' records whom the user has sent mail to or received mail from
        let contactsURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/contacts"
        
        PersonService.getPeopleCollection(contactsURL, headers: nil, completion: { (error, result) -> Void in
            if let peopleArray = result as? Array<Person> {
                penpals = peopleArray
            }
        })
    }
    
    class func getPersonFromUsername(username: String) -> Person? {
        if username == loggedInUser.username {
            return loggedInUser
        }
        else if penpals.filter({$0.username == username}).count == 1 {
            return penpals.filter({$0.username == username})[0]
        }
        else {
            return nil
        }
    }
    
}