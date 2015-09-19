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
import SwiftyJSON

class CoreDataService {
    
    class func getIfModifiedSinceHeaderForEntity(entityName: String, managedContext: NSManagedObjectContext) -> [String: String]? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        let fetchedResults = self.executeFetchRequest(managedContext, fetchRequest: fetchRequest)
        
        if fetchedResults != nil {
            let maxUpdatedAt = fetchedResults![0].valueForKey("updatedAtString") as! String
            let headers = ["IF_MODIFIED_SINCE": maxUpdatedAt]
            return headers
        }
        else {
            return nil
        }
    
    }
    
    class func getCoreDataObjectForJson(json: JSON, entityName: String, managedContext: NSManagedObjectContext) -> NSManagedObject {
        let predicate = NSPredicate(format: "id == %@", json["_id"]["$oid"].stringValue)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
        
        if fetchResults!.count > 0 {
            return fetchResults![0]
        }
        else {
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
            let newObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            return newObject
        }
        
    }
    
    class func initializeManagedContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        return managedContext
    }
    
    class func findObjectById(managedContext: NSManagedObjectContext, id:String, entityName: String) -> NSManagedObject {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        let objects = self.executeFetchRequest(managedContext, fetchRequest: fetchRequest)
        
        return objects![0]

    }
    
    class func executeFetchRequest(managedContext: NSManagedObjectContext, fetchRequest: NSFetchRequest) -> [NSManagedObject]? {
        var objects:[NSManagedObject]!
        
        do {
            objects = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            fatalError("Failed to fetch objects: \(error)")
        }
        
        return objects
    }
    
    class func deleteCoreDataObjects(entityName: String, managedContext: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for object:NSManagedObject in fetchedResults! {
                managedContext.deleteObject(object)
            }
        }
        catch {
            print(error)
        }
    }
    
//    class func getCoreDataObjectsForJsonArray(jsonArray: [AnyObject], entityName: String) -> [NSManagedObject] {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        
//        for object in jsonArray {
//            let json = JSON(object)
//            let predicate = NSPredicate(format: "id == %@", json["_id"]["$oid"].stringValue)
//            let object = CoreDataService.getExistingEntityOrReturnNewEntity(entityName, managedContext: managedContext, predicate: predicate)
//            self.addOrUpdateCoreDataEntityFromJson(json, object: object, managedContext: managedContext)
//        }
//    }
//    
//    class func getExistingEntityOrReturnNewEntity(entityName: String, managedContext: NSManagedObjectContext, predicate: NSPredicate) -> NSManagedObject {
//        
//        let fetchRequest = NSFetchRequest(entityName: entityName)
//        fetchRequest.predicate = predicate
//        
//        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
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
    
//    /// Mark: Old functions
//    
//    class func getObjectsFromCoreData(fetchRequest: NSFetchRequest, predicate: NSPredicate?) -> [NSManagedObject]? {
//        //        let fetchRequest = NSFetchRequest(entityName: entityName)
//
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        
//        if predicate != nil {
//            fetchRequest.predicate = predicate!
//        }
//        
//        var fetchedResults:[NSManagedObject]!
//        
//        do {
//            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
//        }
//        catch {
//            print(error)
//        }
//        
//        return fetchedResults!
//        
//    }
    
}