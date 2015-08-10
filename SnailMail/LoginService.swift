//
//  DataManager.swift
//  Slowpost
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

}