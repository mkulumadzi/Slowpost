//
//  CoreDataService.swift
//  Slowpost
//
//  Created by Evan Waters on 8/6/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataService {
    
    class func getObjectsFromCoreData(entityName: String, predicate: NSPredicate) -> [NSManagedObject] {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //This is the only part of this function that is unique... could generalize it
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        return fetchedResults!
    }
    
    class func deleteCoreDataObjects(entityName: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        for object:NSManagedObject in fetchedResults! {
            managedContext.deleteObject(object)
        }
        
    }
    
}