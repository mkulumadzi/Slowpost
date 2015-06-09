//
//  DataManager.swift
//  SnailMail
//
//  Created by Evan Waters on 3/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire


//URL for Heroku instance of PostOfice server
let PostOfficeURL = "https://safe-ocean-2040.herokuapp.com/"

class DataManager {
   
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
        let name:String = jsonEntry.objectForKey("name") as! String
        let address1 = jsonEntry.objectForKey("address1") as? String
        let city = jsonEntry.objectForKey("city") as? String
        let state = jsonEntry.objectForKey("state") as? String
        let zip = jsonEntry.objectForKey("zip") as? String
        
        var new_person = Person(id: id, username: username, name: name, address1: address1, city: city, state: state, zip: zip)
        
        return new_person
    }

    class func getMyMailboxWithSuccess(success: ((mailData: NSData!) -> Void)) {
        
        loadDataFromURL(NSURL(string: "\(PostOfficeURL)/person/id/\(loggedInUser.id)/mailbox")!, completion: {(data,error) -> Void in
            
            if let urlData = data {
                success(mailData: urlData)
            }
        })
        
    }
    
    class func getAllPeopleWithSuccess(success: ((peopleData: NSData!) -> Void)) {
        
        loadDataFromURL(NSURL(string: "\(PostOfficeURL)/people")!, completion: {(data,error) -> Void in
            
            if let urlData = data {
                success(peopleData:urlData)
            }
        })
    }
    
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        var session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"com.bigedubs", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        
        loadDataTask.resume()
    }
    

}