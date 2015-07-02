//
//  DataManager.swift
//  SnailMail
//
//  Created by Evan Waters on 3/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import CoreData


//URL for Heroku instance of PostOfice server
let PostOfficeURL = DataManager.getPostOfficeURL()

class DataManager {
    
    func getManagedContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        return managedContext
    }

    class func getCurrentConfiguration() -> String {
        var myDict: NSDictionary?
        var currentConfiguration = ""
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            currentConfiguration = dict["Configuration"] as! String
        }
        
        return currentConfiguration
    }
    
    class func getPostOfficeURL() -> String {
        var myDict: NSDictionary?
        var currentConfiguration = getCurrentConfiguration()
        var postOfficeURL = ""
        
        if let path = NSBundle.mainBundle().pathForResource("Configurations", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            var configDict: NSDictionary = (dict[currentConfiguration] as? NSDictionary)!
            postOfficeURL = configDict["PostOfficeURL"] as! String
        }
        
        return postOfficeURL
    }
   
      class func getPerson(personURL:String, completion: (error: NSError?, result: AnyObject?) -> Void) {
    
            Alamofire.request(.GET, personURL)
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
                    if let response = JSON as? NSDictionary {
                        var person:Person! = self.createPersonFromJson(response)
                        completion(error: nil, result: person)
                    }
            }
            
        }
    
    class func getPeople(parameters:String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let peopleURL = "\(PostOfficeURL)people?\(parameters)"
        
        Alamofire.request(.GET, peopleURL)
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
                    println("Unexpected JSON result")
                }
        }
    }
    
    class func createPersonFromJson(jsonEntry: NSDictionary) -> Person {
        
        let id = jsonEntry.objectForKey("_id")!.objectForKey("$oid") as! String
        let username:String = jsonEntry.objectForKey("username") as! String
        let name = jsonEntry.objectForKey("name") as? String
        let address1 = jsonEntry.objectForKey("address1") as? String
        let city = jsonEntry.objectForKey("city") as? String
        let state = jsonEntry.objectForKey("state") as? String
        let zip = jsonEntry.objectForKey("zip") as? String
        
        let updatedString = jsonEntry.objectForKey("updated_at") as! String
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry.objectForKey("created_at") as! String
        let createdAt = NSDate(dateString: createdString)
        
        var new_person = Person(id: id, username: username, name: name, address1: address1, city: city, state: state, zip: zip, updatedAt: updatedAt, createdAt: createdAt)
        
        return new_person
    }
    
    class func getMyMailbox( completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let mailboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/mailbox"
        
        Alamofire.request(.GET, mailboxURL)
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
                    var mail_array = [Mail]()
                    for jsonEntry in jsonResult {
                        mail_array.append(self.createMailFromJson(jsonEntry))
                    }
                    completion(error: nil, result: mail_array)
                }
                else {
                    println("Unexpected JSON result")
                }
        }
    }
    
    class func getMyOutbox( completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let mailboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/outbox"
        
        Alamofire.request(.GET, mailboxURL)
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
                    var mail_array = [Mail]()
                    for jsonEntry in jsonResult {
                        mail_array.append(self.createMailFromJson(jsonEntry))
                    }
                    completion(error: nil, result: mail_array)
                }
                else {
                    println("Unexpected JSON result")
                }
        }
    }
    
    
    class func createMailFromJson(jsonEntry: NSDictionary) -> Mail {
        
        let id = jsonEntry.objectForKey("_id")!.objectForKey("$oid") as! String
        let status = jsonEntry.objectForKey("status") as! String
        let from = jsonEntry.objectForKey("from") as! String
        let to = jsonEntry.objectForKey("to") as! String
        let content = jsonEntry.objectForKey("content") as! String
        let image = jsonEntry.objectForKey("image") as? String
        
        let arrivalString = jsonEntry.objectForKey("scheduled_to_arrive") as? String
        let scheduledToArrive = NSDate(dateString: arrivalString!)
        
        let updatedString = jsonEntry.objectForKey("updated_at") as! String
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry.objectForKey("created_at") as! String
        let createdAt = NSDate(dateString: createdString)
        
        
        var new_mail = Mail(id: id, status: status, from: from, to: to, content: content, image: image, scheduledToArrive: scheduledToArrive, updatedAt: updatedAt, createdAt: createdAt)
        
        return new_mail
    }
    
    func savePerson(person: Person) {
        
        let managedContext = getManagedContext()
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
        
        let tempPerson = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        tempPerson.setValue(person.id, forKey: "id")
        tempPerson.setValue(person.name, forKey: "name")
        tempPerson.setValue(person.username, forKey: "username")
        tempPerson.setValue(person.address1, forKey: "address1")
        tempPerson.setValue(person.city, forKey: "city")
        tempPerson.setValue(person.state, forKey: "state")
        tempPerson.setValue(person.zip, forKey: "zip")
        tempPerson.setValue(person.createdAt, forKey: "createdAt")
        tempPerson.setValue(person.updatedAt, forKey: "updatedAt")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        coreDataPeople.append(tempPerson)
    }
    
    class func saveLoginToSession(username: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Session", inManagedObjectContext: managedContext)
        
        let session = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        session.setValue(username, forKey: "loggedInUser")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Error saving session \(error), \(error?.userInfo)")
        }
        
    }
    
    class func getUsernameFromSession() -> String {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Session")
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let session = fetchedResults {
            if session.count > 0 {
                var username = session[0].valueForKey("loggedInUser") as? String
                return username!
                }
            }
        
        return ""
    }
    
    class func updatePerson(person: Person, parameters: [String: String], completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(person.id)"
        
        Alamofire.request(.POST, updatePersonURL, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 204 {
                        completion(error: nil, result: "Update succeeded")
                    }
                }
        }
        
    }

}