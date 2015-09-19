//
//  ConversationService.swift
//  Slowpost
//
//  Created by Evan Waters on 9/1/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class ConversationService: PostofficeObjectService {
    
    class func updateConversations(managedContext: NSManagedObjectContext) {
        print("Updating conversations at \(NSDate())")
        let conversationsURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/conversations"
        let headers = CoreDataService.getIfModifiedSinceHeaderForEntity("Conversation", managedContext: managedContext)
        RestService.getRequest(conversationsURL, headers: headers, completion: { (error, result) -> Void in
            if let jsonArray = result as? [AnyObject] {
                self.appendJsonArrayToCoreData(jsonArray, managedContext: managedContext)
            }
        })
    }
    
    class func appendJsonArrayToCoreData(jsonArray: [AnyObject], managedContext: NSManagedObjectContext) {
        let entityName = "Conversation"
        for item in jsonArray {
            let json = JSON(item)
            let object = CoreDataService.getCoreDataObjectForJson(json, entityName: entityName, managedContext: managedContext)
            self.addOrUpdateCoreDataEntityFromJson(json, object: object, managedContext: managedContext)
        }
    }
    
    override class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject, managedContext: NSManagedObjectContext) {
        let conversation = object as! Conversation
        self.addPeople(conversation, json: json, managedContext: managedContext)
        conversation.emails = json["emails"].stringValue
        conversation.numUnread = json["numUnread"].intValue
        conversation.numUndelivered = json["numUndelivered"].intValue
        conversation.personSentMostRecentMail = json["personSentMostRecentMail"].boolValue
        
        super.addOrUpdateCoreDataEntityFromJson(json, object: conversation, managedContext: managedContext)
    }
    
    class func addPeople(conversation: Conversation, json: JSON, managedContext: NSManagedObjectContext) {
        for person_id in json["people"].arrayValue {
            let id = person_id["$oid"].stringValue
            let person = CoreDataService.findObjectById(managedContext, id: id, entityName: "Person") as! Person
            conversation.people.append(person)
        }
    }
    
    /// Mark: Old functions
    
//    func getConversationMetadata() {
//        print("Getting the conversation metadata at \(NSDate())")
//        let coreDataConversationMetadata = ConversationMetadataService.populateConversationMetadataArrayFromCoreData()
//        if coreDataConversationMetadata != nil {
//            conversationMetadataArray = coreDataConversationMetadata!
//        }
//        
//        var headers:[String: String]?
//        if conversationMetadataArray.count > 0 {
//            headers = RestService.sinceHeader(conversationMetadataArray)
//        }
//        
//        ConversationMetadataService.getConversationMetadataCollection(headers, completion: { (error, result) -> Void in
//            if let newArray = result as? Array<ConversationMetadata> {
//                ConversationMetadataService.updateConversationMetadataAndAppendArrayToCache(newArray)
//            }
//        })
//    }
//    
//    class func createConversationMetadataFromJson(json: JSON) -> ConversationMetadata {
//        
//        let username = json["username"].stringValue
//        let name = json["name"].stringValue
//        let numUnread = json["num_unread"].intValue
//        let numUndelivered = json["num_undelivered"].intValue
//        
//        let updatedAtString = json["updated_at"].stringValue
//        let updatedAt = NSDate(dateString: updatedAtString)
//        
//        let mostRecentStatus = json["most_recent_status"].stringValue
//        let mostRecentSender = json["most_recent_sender"].stringValue
//        
//        let conversationMetadata = ConversationMetadata(username: username, name: name, numUnread: numUnread, numUndelivered: numUndelivered, updatedAt: updatedAt, updatedAtString: updatedAtString, mostRecentStatus: mostRecentStatus, mostRecentSender: mostRecentSender)
//        
//        return conversationMetadata
//    }
//    
//    class func populateConversationMetadataArrayFromCoreData() -> [ConversationMetadata]? {
//        
//        let conversationMetadataCoreData = CoreDataService.getObjectsFromCoreData("ConversationMetadata", predicate: nil)
//        var conversationMetadataArray = [ConversationMetadata]()
//        
//        for nsManagedObject in conversationMetadataCoreData {
//            conversationMetadataArray.append(self.createConversationMetadataFromCoreData(nsManagedObject))
//        }
//        
//        return conversationMetadataArray
//    }
//    
//    class func createConversationMetadataFromCoreData(object: NSManagedObject) -> ConversationMetadata {
//        
//        let username = object.valueForKey("username") as! String
//        let name = object.valueForKey("name") as! String
//        let numUnread = object.valueForKey("numUnread") as! Int
//        let numUndelivered = object.valueForKey("numUndelivered") as! Int
//        let updatedAt = object.valueForKey("updatedAt") as? NSDate
//        let updatedAtString = object.valueForKey("updatedAtString") as! String
//        let mostRecentStatus = object.valueForKey("mostRecentStatus") as! String
//        let mostRecentSender = object.valueForKey("mostRecentSender") as! String
//    
//        let newConversationMetadata = ConversationMetadata(username: username, name: name, numUnread: numUnread, numUndelivered: numUndelivered, updatedAt: updatedAt!, updatedAtString: updatedAtString, mostRecentStatus: mostRecentStatus, mostRecentSender: mostRecentSender)
//        
//        return newConversationMetadata
//    }
//    
//    class func appendConversationMetadataArrayToCoreData(conversationMetadataArray: [ConversationMetadata]) {
//        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        
//        for conversationMetadata in conversationMetadataArray {
//            let predicate = NSPredicate(format: "username == %@", conversationMetadata.username)
//            
//            let object = CoreDataService.getExistingEntityOrReturnNewEntity("ConversationMetadata", managedContext: managedContext, predicate: predicate)
//            self.saveOrUpdateConversationMetadataInCoreData(conversationMetadata, object: object, managedContext: managedContext)
//        }
//        
//    }
//    
//    class func saveOrUpdateConversationMetadataInCoreData(conversationMetadata: ConversationMetadata, object: NSManagedObject, managedContext: NSManagedObjectContext) {
//        
//        object.setValue(conversationMetadata.username, forKey: "username")
//        object.setValue(conversationMetadata.name, forKey: "name")
//        object.setValue(conversationMetadata.numUnread, forKey: "numUnread")
//        object.setValue(conversationMetadata.numUndelivered, forKey: "numUndelivered")
//        object.setValue(conversationMetadata.updatedAt, forKey: "updatedAt")
//        object.setValue(conversationMetadata.updatedAtString, forKey: "updatedAtString")
//        object.setValue(conversationMetadata.mostRecentStatus, forKey: "mostRecentStatus")
//        object.setValue(conversationMetadata.mostRecentSender, forKey: "mostRecentSender")
//        
//        var error: NSError?
//        do {
//            try managedContext.save()
//        } catch let error1 as NSError {
//            error = error1
//            print("Error saving conversation metadata \(error), \(error?.userInfo)")
//        }
//        
//    }
//    
//    class func getConversationMetadataCollection(headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
//        let conversationMetadataURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/conversations"
//        
//        RestService.getRequest(conversationMetadataURL, headers: headers, completion: { (error, result) -> Void in
//            if error != nil {
//                print(error)
//                completion(error: error, result: nil)
//            }
//            else {
//                if let jsonArray = result as? [AnyObject] {
//                    for jsonEntry in jsonArray {
//                        let json = JSON(jsonEntry)
//                        conversationMetadataArray.append(self.createConversationMetadataFromJson(json))
//                    }
//                    completion(error: nil, result: conversationMetadataArray)
//                }
//                else {
//                    completion(error: nil, result: "Unexpected result when getting people collection")
//                }
//            }
//        })
//    }
//    
//    class func updateConversationMetadataCollectionFromArray(existingCollection: [ConversationMetadata], newCollection: [ConversationMetadata]) -> [ConversationMetadata] {
//        
//        //Creating a mutable collection of conversation metadata from the existing collection
//        var updatedCollection:[ConversationMetadata] = existingCollection
//        
//        //Update existing item
//        for conversationMetadata in newCollection {
//            if updatedCollection.filter({$0.username == conversationMetadata.username}).count > 0 {
//                let existingMetadata:ConversationMetadata = updatedCollection.filter({$0.username == conversationMetadata.username}).first!
//                let existingIndex:Int = updatedCollection.indexOf(existingMetadata)!
//                updatedCollection[existingIndex] = conversationMetadata
//            }
//                // Append new item
//            else {
//                updatedCollection.append(conversationMetadata)
//            }
//        }
//        
//        return updatedCollection
//        
//    }
//    
//    class func updateConversationMetadataAndAppendArrayToCache(newArray: [ConversationMetadata]) {
//        
//        conversationMetadataArray = self.updateConversationMetadataCollectionFromArray(conversationMetadataArray, newCollection: newArray)
//        conversationMetadataArray = conversationMetadataArray.sort { $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending }
//        self.appendConversationMetadataArrayToCoreData(newArray)
//    }
    
}