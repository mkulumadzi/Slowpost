//
//  PostofficeObjectService.swift
//  Slowpost
//
//  Created by Evan Waters on 9/18/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class PostofficeObjectService {
    
    class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject, dataController: DataController) {
        let postofficeObject = object as! PostofficeObject
        postofficeObject.id = json["_id"]["$oid"].stringValue
        postofficeObject.updatedAt = NSDate(dateString: json["updated_at"].stringValue)
        postofficeObject.createdAt = NSDate(dateString: json["created_at"].stringValue)
        
        dataController.save()
        
    }
    
//    class func populateObjectArrayFromCoreData(predicate: NSPredicate, entityName: String) -> [PostofficeObject] {
//        
//        var objectArray = [PostofficeObject]()
//        
//        let objectsFromCoreData = CoreDataService.getObjectsFromCoreData(entityName, predicate: predicate)
//        
//        for nsManagedObject in objectsFromCoreData {
//            objectArray.append(self.createObjectFromCoreData(nsManagedObject))
//        }
//        
//        return objectArray
//    }
//    
//    class func createObjectFromCoreData(object: NSManagedObject) -> PostofficeObject {
//        let id = object.valueForKey("id") as! String
//        let updatedAt = object.valueForKey("updatedAt") as! NSDate
//        let updatedAtString = object.valueForKey("updatedAtString") as! String
//        let createdAt = object.valueForKey("createdAt") as! NSDate
//        
//        let newObject = PostofficeObject(id: id, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
//        
//        return newObject
//    }
    
}