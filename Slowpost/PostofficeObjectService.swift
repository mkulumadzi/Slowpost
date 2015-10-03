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
    
    class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let postofficeObject = object as! PostofficeObject
        postofficeObject.id = json["_id"]["$oid"].stringValue
        postofficeObject.updatedAt = NSDate(dateString: json["updated_at"].stringValue)
        postofficeObject.createdAt = NSDate(dateString: json["created_at"].stringValue)
        
        dataController.save()
        
    }
        
}