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
                    var person:Person!
                    var response = JSON as! NSDictionary
                    var id:String = response.objectForKey("_id")!.objectForKey("$oid") as! String
                    var name:String = response.objectForKey("name") as! String
                    var username:String = response.objectForKey("username") as! String
                    person = Person(id: id, username: username, name: name, address1: nil, city: nil, state: nil, zip: nil)
                    completion(error: nil, result: person)
            }
            
        }
    
    class func getPeople(parameters:String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let peopleURL = "\(PostOfficeURL)people?\(parameters)"
        println(peopleURL)
        
        Alamofire.request(.GET, peopleURL)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 404 {
                        completion(error: error, result: response.statusCode)
                    }
//                    else if response.statusCode == 200 {
//                        println(data)
//                        completion(error: nil, result: data)
//                    }
                }
        }
            .responseJSON { (_, _, JSON, error) in
                var response = JSON as! NSArray
                println(response)
                completion(error: nil, result: response)
        }
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