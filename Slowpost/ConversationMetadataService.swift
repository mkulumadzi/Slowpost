//
//  ConversationMetadataService.swift
//  Slowpost
//
//  Created by Evan Waters on 9/1/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class ConversationMetadataService {
    
    class func createConversationMetadataFromJson(jsonEntry: NSDictionary) -> ConversationMetadata {
        println("creating CM from json")
        
        let username = jsonEntry.objectForKey("username") as! String
        let name = jsonEntry.objectForKey("name") as! String
        let numUnread = jsonEntry.objectForKey("num_unread") as! Int
        let numUndelivered = jsonEntry.objectForKey("num_undelivered") as! Int
        
        let updatedAtString = jsonEntry.objectForKey("updated_at") as! String
        let updatedAt = NSDate(dateString: updatedAtString)
        
        let mostRecentStatus = jsonEntry.objectForKey("most_recent_status") as! String
        let mostRecentSender = jsonEntry.objectForKey("most_recent_sender") as! String
        
        var conversationMetadata = ConversationMetadata(username: username, name: name, numUnread: numUnread, numUndelivered: numUndelivered, updatedAt: updatedAt, updatedAtString: updatedAtString, mostRecentStatus: mostRecentStatus, mostRecentSender: mostRecentSender)
        
        return conversationMetadata
    }
    
    class func populateConversationMetadataArrayFromCoreData() -> [ConversationMetadata]? {
        println("populating from core data")
        
        let conversationMetadataCoreData = CoreDataService.getObjectsFromCoreData("ConversationMetadata", predicate: nil)
        var conversationMetadataArray = [ConversationMetadata]()
        
        for nsManagedObject in conversationMetadataCoreData {
            conversationMetadataArray.append(self.createConversationMetadataFromCoreData(nsManagedObject))
        }
        
        return conversationMetadataArray
    }
    
    class func createConversationMetadataFromCoreData(object: NSManagedObject) -> ConversationMetadata {
        println("creating from core data")
        
        let username = object.valueForKey("username") as! String
        let name = object.valueForKey("name") as! String
        let numUnread = object.valueForKey("numUnread") as! Int
        let numUndelivered = object.valueForKey("numUndelivered") as! Int
        let updatedAt = object.valueForKey("updatedAt") as? NSDate
        let updatedAtString = object.valueForKey("updatedAtString") as! String
        let mostRecentStatus = object.valueForKey("mostRecentStatus") as! String
        let mostRecentSender = object.valueForKey("mostRecentSender") as! String
    
        var newConversationMetadata = ConversationMetadata(username: username, name: name, numUnread: numUnread, numUndelivered: numUndelivered, updatedAt: updatedAt!, updatedAtString: updatedAtString, mostRecentStatus: mostRecentStatus, mostRecentSender: mostRecentSender)
        
        return newConversationMetadata
    }
    
    class func appendConversationMetadataArrayToCoreData(conversationMetadataArray: [ConversationMetadata]) {
        println("appending array to core data")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        for conversationMetadata in conversationMetadataArray {
            let predicate = NSPredicate(format: "username == %@", conversationMetadata.username)
            
            let object = CoreDataService.getExistingEntityOrReturnNewEntity("ConversationMetadata", managedContext: managedContext, predicate: predicate)
            self.saveOrUpdateConversationMetadataInCoreData(conversationMetadata, object: object, managedContext: managedContext)
        }
        
    }
    
    class func saveOrUpdateConversationMetadataInCoreData(conversationMetadata: ConversationMetadata, object: NSManagedObject, managedContext: NSManagedObjectContext) {
        println("saving or updating core data")
        
        object.setValue(conversationMetadata.username, forKey: "username")
        object.setValue(conversationMetadata.name, forKey: "name")
        object.setValue(conversationMetadata.numUnread, forKey: "numUnread")
        object.setValue(conversationMetadata.numUndelivered, forKey: "numUndelivered")
        object.setValue(conversationMetadata.updatedAt, forKey: "updatedAt")
        object.setValue(conversationMetadata.updatedAtString, forKey: "updatedAtString")
        object.setValue(conversationMetadata.mostRecentStatus, forKey: "mostRecentStatus")
        object.setValue(conversationMetadata.mostRecentSender, forKey: "mostRecentSender")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Error saving conversation metadata \(error), \(error?.userInfo)")
        }
        
    }
    
    class func getConversationMetadataCollection(headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let conversationMetadataURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/conversations"
        
        println("getting CM from postoffice")
        
        RestService.getRequest(conversationMetadataURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
                completion(error: error, result: nil)
            }
            else if let jsonResult = result as? Array<NSDictionary> {
                var conversationMetadataArray = [ConversationMetadata]()
                for jsonEntry in jsonResult {
                    conversationMetadataArray.append(self.createConversationMetadataFromJson(jsonEntry))
                }
                completion(error: nil, result: conversationMetadataArray)
            }
            else {
                println("Unexpected JSON result while getting conversation metadata")
            }
        })
    }
    
    class func updateConversationMetadataCollectionFromArray(existingCollection: [ConversationMetadata], newCollection: [ConversationMetadata]) -> [ConversationMetadata] {
        
        println("updating metadata from array")
        
        //Creating a mutable collection of conversation metadata from the existing collection
        var updatedCollection:[ConversationMetadata] = existingCollection
        
        //Update existing item
        for conversationMetadata in newCollection {
            if updatedCollection.filter({$0.username == conversationMetadata.username}).count > 0 {
                var existingMetadata:ConversationMetadata = updatedCollection.filter({$0.username == conversationMetadata.username}).first!
                var existingIndex:Int = find(updatedCollection, existingMetadata)!
                updatedCollection[existingIndex] = conversationMetadata
            }
                // Append new item
            else {
                updatedCollection.append(conversationMetadata)
            }
        }
        
        return updatedCollection
        
    }
    
    class func updateConversationMetadataAndAppendArrayToCache(newArray: [ConversationMetadata]) {
        println("updating and appending to cache")
        
        conversationMetadataArray = self.updateConversationMetadataCollectionFromArray(conversationMetadataArray, newCollection: newArray)
        conversationMetadataArray = conversationMetadataArray.sorted { $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending }
        self.appendConversationMetadataArrayToCoreData(newArray)
    }
    
}