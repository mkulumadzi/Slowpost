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
import SwiftyJSON

class LoginService {
    
    class func saveLoginToSession(userId: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Session", inManagedObjectContext: managedContext)
        
        let session = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        session.setValue(userId, forKey: "loggedInUserId")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Error saving session \(error), \(error?.userInfo)")
        }
        
    }
    
    class func getUserIdFromSession() -> String {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Session")
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let session = fetchedResults {
            if session.count > 0 {
                if let id = session[0].valueForKey("loggedInUserId") as? String {
                    return id
                }
            }
        }
        
        return ""
    }
    
    class func resetPassword(person: Person, parameters: [String: String], completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let resetPasswordURL = "\(PostOfficeURL)/person/id/\(person.id)/reset_password"
        
        Alamofire.request(.POST, resetPasswordURL, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 204 {
                        completion(error: nil, result: "Success")
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let response_body = JSON as? NSDictionary {
                    if let error_message = response_body["message"] as? String {
                        completion(error: nil, result: ["Failure", error_message])
                    }
                    else {
                        println("No error message")
                    }
                }
        }
        
    }
    
    class func signUp(parameters: [String: String], completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let newPersonEndpoint = "\(PostOfficeURL)person/new"
        
        Alamofire.request(.POST, newPersonEndpoint, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 201 {
                        completion(error: nil, result: ["Success", response.allHeaderFields["Location"] as! String])
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let response_body = JSON as? NSDictionary {
                    if let error_message = response_body["message"] as? String {
                        completion(error: nil, result: ["Failure", error_message])
                    }
                    else {
                        println("No error message")
                    }
                }
        }
    }

}