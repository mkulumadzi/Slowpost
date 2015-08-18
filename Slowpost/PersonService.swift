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
    
    class func savePersonToCoreData(person: Person) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
        let cdPerson = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        cdPerson.setValue(person.id, forKey: "id")
        cdPerson.setValue(person.username, forKey: "username")
        cdPerson.setValue(person.name, forKey: "name")
        cdPerson.setValue(person.email, forKey: "email")
        cdPerson.setValue(person.phone, forKey: "phone")
        cdPerson.setValue(person.address1, forKey: "address1")
        cdPerson.setValue(person.city, forKey: "city")
        cdPerson.setValue(person.state, forKey: "state")
        cdPerson.setValue(person.zip, forKey: "zip")
        cdPerson.setValue(person.updatedAt, forKey: "updatedAt")
        cdPerson.setValue(person.updatedAtString, forKey: "updatedAtString")
        cdPerson.setValue(person.createdAt, forKey: "createdAt")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Error saving person \(error), \(error?.userInfo)")
        }
        
    }
    
    class func getPeopleObjectsFromCoreData() -> [NSManagedObject] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        return fetchedResults!
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
    
    class func getPerson(personId: String, headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let personURL = "\(PostOfficeURL)/person/id/\(personId)"
        RestService.getRequest(personURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                completion(error: error, result: nil)
            }
            else if let dict = result as? NSDictionary {
                var person:Person = self.createPersonFromJson(dict)
                completion(error: nil, result: person)
            }
            else {
                completion(error: nil, result: "Unexpected result while getting person")
            }
        })
        
    }
    
    class func getPeopleCollection(collectionURL: String, headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        RestService.getRequest(collectionURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
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
    
    class func checkFieldAvailability(params: [String: String], completion: (error: NSError?, result: AnyObject?) -> Void) {
        var key:String = Array(params.keys)[0]
        var value:String = params[key]!
        
        let availableURL = "\(PostOfficeURL)/available?\(key)=\(value)"
        
        RestService.getRequest(availableURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                completion(error: error, result: nil)
            }
            else if let jsonResult = result as? NSDictionary {
                completion(error: nil, result: jsonResult)
            }
            else {
                println("Unexpected JSON result getting \(availableURL)")
            }
        })
    }
    
    
    //Bulk search of people based on a users' contact info
    class func bulkPersonSearch(parameters: [NSDictionary], completion: (error: NSError?, result: AnyObject?) -> Void) {
        
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
    
}