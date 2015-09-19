//
//  MailService.swift
//  Slowpost
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class MailService: PostofficeObjectService {
    
    class func updateMailbox() {
        let mailURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mailbox"
        // To Do: Get headers using a query of core data
        self.updateMail(mailURL, headers: nil)
    }
    
    class func updateOutbox() {
        let mailURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/outbox"
        // To Do: Get headers using a query of core data
        self.updateMail(mailURL, headers: nil)
    }
    
    class func updateConversationMail(conversationId: String) {
        let mailURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/conversation/\(conversationId)"
        // To Do: Get headers using a query of core data
        self.updateMail(mailURL, headers: nil)
    }
    
    class func updateMail(mailURL: String, headers:[String: String]?) {
        print("Updating mail at \(NSDate())")
        RestService.getRequest(mailURL, headers: headers, completion: { (error, result) -> Void in
            if let jsonArray = result as? [AnyObject] {
                self.appendJsonArrayToCoreData(jsonArray)
            }
        })
    }
    
    class func appendJsonArrayToCoreData(jsonArray: [AnyObject]) {
        let entityName = "Mail"
        let managedContext = CoreDataService.initializeManagedContext()
        for item in jsonArray {
            let json = JSON(item)
            let object = CoreDataService.getCoreDataObjectForJson(json, entityName: entityName, managedContext: managedContext)
            self.addOrUpdateCoreDataEntityFromJson(json, object: object, managedContext: managedContext)
        }
    }
    
    override class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject, managedContext: NSManagedObjectContext) {
        
        object.setValue(json["status"].stringValue, forKey: "status")
        object.setValue(json["type"].stringValue, forKey: "type")
        
        // Relationships here
    
        object.setValue(NSDate(dateString: json["date_sent"].stringValue), forKey: "dateSent")
        object.setValue(NSDate(dateString: json["scheduled_to_arrive"].stringValue), forKey: "scheduledToArrive")
        object.setValue(NSDate(dateString: json["date_delivered"].stringValue), forKey: "dateDelivered")
        object.setValue(json["my_info"]["status"].stringValue, forKey: "myStatus")
        
        super.addOrUpdateCoreDataEntityFromJson(json, object: object, managedContext: managedContext)
    }
    
    /// Mark: Old functions
    
    class func createMailFromJson(jsonEntry: JSON) -> Mail {
        
        print(jsonEntry)
        
        let id = jsonEntry["_id"]["$oid"].stringValue
        
        print("Creating mail \(id)")
        
        let status = jsonEntry["status"].stringValue
        let from = jsonEntry["from"].stringValue
        let to = jsonEntry["to"].stringValue
        let content = jsonEntry["content"].stringValue
        let imageUid = jsonEntry["image_uid"].stringValue
        
        var image:UIImage?
        if imageUid == "" {
            image = UIImage(named: "Default Card.png")!
        }
        
        let arrivalString = jsonEntry["scheduled_to_arrive"].stringValue
        
        var scheduledToArrive:NSDate!
        if arrivalString != "" {
            scheduledToArrive = NSDate(dateString: arrivalString)
        }
        
        let updatedString = jsonEntry["updated_at"].stringValue
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry["created_at"].stringValue
        let createdAt = NSDate(dateString: createdString)
        
        let mail = Mail(id: id, status: status, from: from, to: to, content: content, imageUid: imageUid, currentlyDownloadingImage: false, image: image, scheduledToArrive: scheduledToArrive, updatedAt: updatedAt, updatedAtString: updatedString, createdAt: createdAt)
        
        return mail
    }
    
    class func populateMailArrayFromCoreData(predicate: NSPredicate) -> [Mail]? {
        
        let mailboxCoreData = CoreDataService.getObjectsFromCoreData("Mail", predicate: predicate)
        var mailArray = [Mail]()
        
        for nsManagedObject in mailboxCoreData {
            mailArray.append(self.createMailFromCoreData(nsManagedObject))
        }
        
        return mailArray
    }
    
    class func createMailFromCoreData(object: NSManagedObject) -> Mail {
        let id = object.valueForKey("id") as! String
        let status = object.valueForKey("status") as! String
        let from = object.valueForKey("from") as! String
        let to = object.valueForKey("to") as! String
        let content = object.valueForKey("content") as? String
        let imageUid = object.valueForKey("imageUid") as? String
        
        var image:UIImage!
        if let data = object.valueForKey("image") as? NSData {
            image = UIImage(data: data)
        }
        
        let scheduledToArrive = object.valueForKey("scheduledToArrive") as? NSDate
        let updatedAt = object.valueForKey("updatedAt") as! NSDate
        let updatedAtString = object.valueForKey("updatedAtString") as! String
        let createdAt = object.valueForKey("createdAt") as! NSDate
        
        let newMail = Mail(id: id, status: status, from: from, to: to, content: content, imageUid: imageUid, currentlyDownloadingImage: false, image: image, scheduledToArrive: scheduledToArrive, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
        
        return newMail
    }
    
    class func appendMailArrayToCoreData(mailArray: [Mail]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        for mail in mailArray {
            let predicate = NSPredicate(format: "id == %@", mail.id)
            let object = CoreDataService.getExistingEntityOrReturnNewEntity("Mail", managedContext: managedContext, predicate: predicate)
            self.saveOrUpdateMailInCoreData(mail, object: object, managedContext: managedContext)
        }
        
    }
    
    class func saveOrUpdateMailInCoreData(mail: Mail, object: NSManagedObject, managedContext: NSManagedObjectContext) {
        
        print(mail)
        
        object.setValue(mail.id, forKey: "id")
        object.setValue(mail.status, forKey: "status")
        object.setValue(mail.from, forKey: "from")
        object.setValue(mail.to, forKey: "to")
        object.setValue(mail.content, forKey: "content")
        object.setValue(mail.imageUid, forKey: "imageUid")
        
        if mail.image != nil {
            object.setValue(UIImagePNGRepresentation(mail.image), forKey: "image")
        }
        
        object.setValue(mail.scheduledToArrive, forKey: "scheduledToArrive")
        object.setValue(mail.updatedAt, forKey: "updatedAt")
        object.setValue(mail.updatedAtString, forKey: "updatedAtString")
        object.setValue(mail.createdAt, forKey: "createdAt")
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print(error.description)
            print(error.userInfo)
        }
        
    }
    
    class func addImageToCoreDataMail(id: String, image: UIImage, key: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Mail")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
        
        for object in fetchResults! {
            object.setValue(UIImagePNGRepresentation(image), forKey: key)
        }
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Error saving person \(error), \(error?.userInfo)")
        }
        
    }
    
    class func getMailById(id: String, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let mailURL = "\(PostOfficeURL)/mail/id/\(id)"
        RestService.getRequest(mailURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
                completion(error: error, result: nil)
            }
            else {
                let json = JSON(result!)
                let mail:Mail = self.createMailFromJson(json)
                completion(error: nil, result: mail)
            }
        })
        
    }
    
    class func getMailImage(mail: Mail, completion: (error: NSError?, result: AnyObject?) -> Void) {

        let mailImageURL = "\(PostOfficeURL)/mail/id/\(mail.id)/image"
        
        FileService.downloadImage(mailImageURL, completion: { (error, result) -> Void in
            if let image = result as? UIImage {
                mail.image = image
                completion(error: nil, result: mail.image)
            }
            else {
                Flurry.logEvent("Failed_To_Download_Image")
                print("Failed to download image")
            }
        })
    }
  
    class func getMailCollection(collectionURL: String, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        RestService.getRequest(collectionURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
                completion(error: error, result: nil)
            }
            else {
                if let jsonArray = result as? [AnyObject] {
                    var mail_array = [Mail]()
                    for jsonEntry in jsonArray {
                        let json = JSON(jsonEntry)
                        mail_array.append(self.createMailFromJson(json))
                    }
                    completion(error: nil, result: mail_array)
                }
                else {
                    completion(error: nil, result: "Unexpected result when getting people collection")
                }
            }
        })
    }
    
    class func updateMailCollectionFromNewMail(existingCollection: [Mail], newCollection: [Mail]) -> [Mail] {
        
        //Creating a mutable collection of mail from the existing collection
        var updatedCollection:[Mail] = existingCollection
        
        //Update existing mail
        for mail in newCollection {
            if updatedCollection.filter({$0.id == mail.id}).count > 0 {
                let existingMail:Mail = updatedCollection.filter({$0.id == mail.id}).first!
                let existingIndex:Int = updatedCollection.indexOf(existingMail)!
                updatedCollection[existingIndex] = mail
            }
                // Append new mail
            else {
                updatedCollection.append(mail)
            }
        }
        
        return updatedCollection
        
    }
    
    class func updateMailboxAndAppendMailToCache(mailArray: [Mail]) {
        mailbox = self.updateMailCollectionFromNewMail(mailbox, newCollection: mailArray)
        mailbox = mailbox.sort { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
        self.appendMailArrayToCoreData(mailArray)
    }
    
    class func updateOutboxAndAppendMailToCache(mailArray: [Mail]) {
        outbox = self.updateMailCollectionFromNewMail(outbox, newCollection: mailArray)
        outbox = outbox.sort { $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedDescending }
        self.appendMailArrayToCoreData(mailArray)
    }
    
}