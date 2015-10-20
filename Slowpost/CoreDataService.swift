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
        let fetchedResults = executeFetchRequest(managedContext, fetchRequest: fetchRequest)
        if fetchedResults != nil {
            let maxUpdatedAt = fetchedResults![0].valueForKey("updatedAt") as! NSDate
            let maxUpdatedAtString = maxUpdatedAt.formattedAsUTCString()
            let headers = ["IF_MODIFIED_SINCE": maxUpdatedAtString]
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
    
    class func findObjectById(managedContext: NSManagedObjectContext, id:String, entityName: String) -> NSManagedObject {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        let objects = executeFetchRequest(managedContext, fetchRequest: fetchRequest)
        
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
    
}