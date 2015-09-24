//
//  DataController.swift
//  Slowpost
//
//  Created by Evan Waters on 9/21/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftyJSON

class DataController: NSObject {
    
    var moc: NSManagedObjectContext
    
    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("SlowpostModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.moc.persistentStoreCoordinator = psc
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            print(docURL)
            /* The directory the application uses to store the Core Data store file.
            This code uses a file named "DataModel.sqlite" in the application's documents directory.
            */
            let storeURL = docURL.URLByAppendingPathComponent("Slowpost.sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
        
    }
    
    func getIfModifiedSinceHeaderForEntity(entityName: String) -> [String: String]? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchLimit = 1
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        let fetchedResults = self.executeFetchRequest(fetchRequest)
        if fetchedResults!.count > 0 {
            let maxUpdatedAt = fetchedResults![0].valueForKey("updatedAt") as! NSDate
            let maxUpdatedAtString = maxUpdatedAt.formattedAsUTCString()
            let headers = ["IF_MODIFIED_SINCE": maxUpdatedAtString]
            return headers
        }
        else {
            return nil
        }
        
    }
    
    func getCoreDataObjectForJson(json: JSON, entityName: String) -> NSManagedObject {
        let id = json["_id"]["$oid"].stringValue
        let object = getCoreDataObject("id == %@", predicateValue: id, entityName: entityName)
        return object
    }
    
    func getCoreDataObject(predicateFormat: String, predicateValue: String, entityName: String) -> NSManagedObject {
        let predicate = NSPredicate(format: predicateFormat, predicateValue)
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        let fetchResults = (try? self.moc.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
        
        if fetchResults!.count > 0 {
            return fetchResults![0]
        }
        else {
            let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: self.moc)
            let newObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.moc)
            return newObject
        }
    }
    
    func findObjectById(id:String, entityName: String) -> NSManagedObject {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        let objects = self.executeFetchRequest(fetchRequest)
        
        return objects![0]
        
    }
    
    func executeFetchRequest(fetchRequest: NSFetchRequest) -> [NSManagedObject]? {
        var objects:[NSManagedObject]!
        do {
            objects = try self.moc.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {
            fatalError("Failed to fetch objects: \(error)")
        }
        
        return objects
    }
    
    
    func deleteCoreDataObjects(entityName: String) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            let fetchedResults = try self.moc.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for object:NSManagedObject in fetchedResults! {
                self.moc.deleteObject(object)
            }
        }
        catch {
            print(error)
        }
    }
    
    func save() {
        do {
            try self.moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
}