//
//  PersonService.swift
//  Snailtale
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

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
        
        var new_person = Person(id: id, username: username, email: email, name: name, phone: phone, address1: address1, city: city, state: state, zip: zip, updatedAt: updatedAt, createdAt: createdAt)
        
        return new_person
    }
    
    class func getPerson(personId: String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let personURL = "\(PostOfficeURL)/person/id/\(personId)"
        RestService.getRequest(personURL, completion: { (error, result) -> Void in
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
    
    //Using penpals to refer to people whom the user has sent mail to, or received mail from. On the postoffice server, this is the /contacts route
    //This function largely duplicates the getPeople function, should consolidate the two
    class func getPenpals(id: String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let contactsURL = "\(PostOfficeURL)person/id/\(id)/contacts"
        
        Alamofire.request(.GET, contactsURL)
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
                    println("Unexpected JSON result for \(contactsURL)")
                }
        }
        
    }
    
    //Searching for people based on partial search strings
    class func searchPeople(term: String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        //Replacing any spaces in the search string with +
        
        var searchString = ""
        if term.rangeOfString(" ") != nil {
            searchString = term.stringByReplacingOccurrencesOfString(" ", withString: "+")
        }
        else {
            searchString = term
        }
        
        //Limiting number of records returned to 10
        let searchPeopleURL = "\(PostOfficeURL)people/search?term=\(searchString)&limit=10"
        
        //Really need to abstract this part instead of just copying and pasting it...
        Alamofire.request(.GET, searchPeopleURL)
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
                    println("Unexpected JSON result for \(searchPeopleURL)")
                }
        }
    }
    
    //Bulk search of people based on a users' contact info
    class func bulkPersonSearch(parameters: [NSDictionary], completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let bulkPersonSearchURL = NSURL.init(string: "\(PostOfficeURL)/people/bulk_search")
        
        let request = NSMutableURLRequest(URL: bulkPersonSearchURL!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &error)
        
        
        //Really need to abstract this part instead of just copying and pasting it...
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