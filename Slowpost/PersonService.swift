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
    
    class func createPersonFromJson(jsonEntry: NSDictionary) -> Person {
        
        let id = jsonEntry.objectForKey("_id")!.objectForKey("$oid") as! String
        let username:String = jsonEntry.objectForKey("username") as! String
        let email = jsonEntry.objectForKey("email") as? String
        let name = jsonEntry.objectForKey("name") as? String
        let phone = jsonEntry.objectForKey("phone") as? String
        let address1 = jsonEntry.objectForKey("address1") as? String
        let city = jsonEntry.objectForKey("city") as? String
        let state = jsonEntry.objectForKey("state") as? String
        let zip = jsonEntry.objectForKey("zip") as? String
        
        let updatedString = jsonEntry.objectForKey("updated_at") as! String
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry.objectForKey("created_at") as! String
        let createdAt = NSDate(dateString: createdString)
        
        var newPerson = Person(id: id, username: username, email: email, name: name, phone: phone, address1: address1, city: city, state: state, zip: zip, updatedAt: updatedAt, updatedAtString: updatedString, createdAt: createdAt)
        
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
        
        var newPerson = Person(id: id, username: username, email: email, name: name, phone: phone, address1: address1, city: city, state: state, zip: zip, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
        
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
        if !managedContext.save(&error) {
            println("Error saving person \(error), \(error?.userInfo)")
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
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        return fetchedResults!
    }
    
    class func getPerson(personId: String, headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let personURL = "\(PostOfficeURL)/person/id/\(personId)"
        RestService.getRequest(personURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
                completion(error: error, result: nil)
            }
            else if let dict = result as? NSDictionary {
                var person:Person = self.createPersonFromJson(dict)
                completion(error: nil, result: person)
            }
            else if let status = result as? Int {
                if status == 304 {
                    completion(error: nil, result: status)
                }
            }
            else {
                completion(error: nil, result: "Unexpected result while getting person")
            }
        })
        
    }
    
    class func getPeopleCollection(collectionURL: String, headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        RestService.getRequest(collectionURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
                completion(error: error, result: nil)
            }
            else if let jsonResult = result as? Array<NSDictionary> {
                var person_array = [Person]()
                for jsonEntry in jsonResult {
                    person_array.append(self.createPersonFromJson(jsonEntry))
                }
                completion(error: nil, result: person_array)
            }
            else {
                println("Unexpected JSON result while getting people")
            }
        })
    }
    
    class func updatePeopleCollectionFromNewPeople(existingCollection: [Person], newCollection: [Person]) -> [Person] {
        
        //Creating a mutable collection of people from the existing collection
        var updatedCollection:[Person] = existingCollection
        
        //Update existing people
        for person in newCollection {
            if updatedCollection.filter({$0.id == person.id}).count > 0 {
                var existingPerson:Person = updatedCollection.filter({$0.id == person.id}).first!
                var existingIndex:Int = find(updatedCollection, existingPerson)!
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
    class func bulkPersonSearch(parameters: [NSDictionary], completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        println(parameters)
        
        let bulkPersonSearchURL = NSURL.init(string: "\(PostOfficeURL)/people/bulk_search")
        
        let request = NSMutableURLRequest(URL: bulkPersonSearchURL!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &error)
        
        Alamofire.request(request)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 404 {
                        completion(error: error, result: response.statusCode)
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let jsonResult = JSON as? Array<NSDictionary> {
                    var people_array = [Person]()
                    for jsonEntry in jsonResult {
                        people_array.append(self.createPersonFromJson(jsonEntry))
                    }
                    completion(error: nil, result: people_array)
                }
                else {
                    println("Unexpected JSON result for \(bulkPersonSearchURL)")
                }
        }
    }
    
    class func parsePersonURLForId(personURL:String) -> String {
        var personURLSplit:[String] = split(personURL) {$0 == "/"}
        var personId:String = personURLSplit.last
        return personId
    }
    
    class func loadPenpals() {
        println("Getting all penpals at \(NSDate())")
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