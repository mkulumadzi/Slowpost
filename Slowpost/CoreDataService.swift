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
    
    class func getObjectsFromCoreData(entityName: String, predicate: NSPredicate?) -> [NSManagedObject] {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }
        
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
    
    class func getExistingEntityOrReturnNewEntity(entityName: String, managedContext: NSManagedObjectContext, predicate: NSPredicate) -> NSManagedObject {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
        
        if fetchResults!.count > 0 {
            return fetchResults![0]
        }
        else {
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
            let newObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            return newObject
        }
    }
    
//    class func getEntityForIdOrReturnNewEntity(id: String, entityName: String, managedContext: NSManagedObjectContext) -> NSManagedObject {
//        
//        let fetchRequest = NSFetchRequest(entityName: entityName)
//        let predicate = NSPredicate(format: "id == %@", id)
//        fetchRequest.predicate = predicate
//        
//        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
//        
//        if fetchResults!.count > 0 {
//            return fetchResults![0]
//        }
//        else {
//            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
//            let newObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
//            return newObject
//        }
//    }
    
}