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

class MailService {
    
    class func createMailFromJson(jsonEntry: NSDictionary) -> Mail {
        
        let id = jsonEntry.objectForKey("_id")!.objectForKey("$oid") as! String
        
        println("Creating mail \(id)")
        
        let status = jsonEntry.objectForKey("status") as! String
        let from = jsonEntry.objectForKey("from") as! String
        let to = jsonEntry.objectForKey("to") as! String
        let content = jsonEntry.objectForKey("content") as? String
        let imageUid = jsonEntry.objectForKey("image_uid") as? String
        
        var image:UIImage?
        var imageThumb:UIImage?
        if imageUid == nil {
            image = UIImage(named: "Default Card.png")!
            imageThumb = UIImage(named: "Default Card.png")!
        }
        
        let arrivalString = jsonEntry.objectForKey("scheduled_to_arrive") as? String
        
        var scheduledToArrive:NSDate!
        if arrivalString != nil {
            scheduledToArrive = NSDate(dateString: arrivalString!)
        }
        
        let updatedString = jsonEntry.objectForKey("updated_at") as! String
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry.objectForKey("created_at") as! String
        let createdAt = NSDate(dateString: createdString)
        
        var mail = Mail(id: id, status: status, from: from, to: to, content: content, imageUid: imageUid, currentlyDownloadingImage: false, image: image, imageThumb: imageThumb, scheduledToArrive: scheduledToArrive, updatedAt: updatedAt, updatedAtString: updatedString, createdAt: createdAt)
        
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
        
        var imageThumb:UIImage!
        if let data = object.valueForKey("imageThumb") as? NSData {
            imageThumb = UIImage(data: data)
        }
        
        let scheduledToArrive = object.valueForKey("scheduledToArrive") as? NSDate
        let updatedAt = object.valueForKey("updatedAt") as! NSDate
        let updatedAtString = object.valueForKey("updatedAtString") as! String
        let createdAt = object.valueForKey("createdAt") as! NSDate
        
        var newMail = Mail(id: id, status: status, from: from, to: to, content: content, imageUid: imageUid, currentlyDownloadingImage: false, image: image, imageThumb: imageThumb, scheduledToArrive: scheduledToArrive, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
        
        return newMail
    }
    
    class func appendMailArrayToCoreData(mailArray: [Mail]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        for mail in mailArray {
            let object = CoreDataService.getEntityForIdOrReturnNewEntity(mail.id, entityName: "Mail", managedContext: managedContext)
            self.saveOrUpdateMailInCoreData(mail, object: object, managedContext: managedContext)
        }
        
    }
    
    class func saveOrUpdateMailInCoreData(mail: Mail, object: NSManagedObject, managedContext: NSManagedObjectContext) {
        
        object.setValue(mail.id, forKey: "id")
        object.setValue(mail.status, forKey: "status")
        object.setValue(mail.from, forKey: "from")
        object.setValue(mail.to, forKey: "to")
        object.setValue(mail.content, forKey: "content")
        object.setValue(mail.imageUid, forKey: "imageUid")
        
        object.setValue(UIImagePNGRepresentation(mail.image), forKey: "image")
        object.setValue(UIImagePNGRepresentation(mail.imageThumb), forKey: "imageThumb")
        
        object.setValue(mail.scheduledToArrive, forKey: "scheduledToArrive")
        object.setValue(mail.updatedAt, forKey: "updatedAt")
        object.setValue(mail.updatedAtString, forKey: "updatedAtString")
        object.setValue(mail.createdAt, forKey: "createdAt")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Error saving person \(error), \(error?.userInfo)")
        }
        
    }
    
    class func addImageToCoreDataMail(id: String, image: UIImage, key: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Mail")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
        
        for object in fetchResults! {
            object.setValue(UIImagePNGRepresentation(image), forKey: key)
        }
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Error saving person \(error), \(error?.userInfo)")
        }
        
    }
    
    class func getMailById(id: String, headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let mailURL = "\(PostOfficeURL)/mail/id/\(id)"
        RestService.getRequest(mailURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
                completion(error: error, result: nil)
            }
            else if let dict = result as? NSDictionary {
                var mail:Mail = self.createMailFromJson(dict)
                completion(error: nil, result: mail)
            }
            else {
                println("Unexpected JSON result for \(mailURL)")
            }
        })
        
    }
    
    class func getMailImage(mail: Mail, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        var thumbSize:String = String(Int(screenWidth)) + "x"
        let mailImageURL = "\(PostOfficeURL)/mail/id/\(mail.id)/image"
        
        FileService.downloadImage(mailImageURL, completion: { (error, result) -> Void in
            if let image = result as? UIImage {
                mail.image = image
                completion(error: nil, result: mail.image)
            }
            else {
                Flurry.logEvent("Failed_To_Download_Image")
                println("Failed to download image")
            }
        })
    }

    class func getMailThumbnailImage(mail: Mail, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let mailThumbnailImageURL = "\(PostOfficeURL)/mail/id/\(mail.id)/thumbnail"
        
        FileService.downloadImage(mailThumbnailImageURL, completion: { (error, result) -> Void in
            if let thumbnail = result as? UIImage {
                mail.imageThumb = thumbnail
                completion(error: nil, result: mail.imageThumb)
            }
            else {
                Flurry.logEvent("Failed_To_Download_Image")
                println("Failed to download image")
            }
        })

    }
    
    class func getMailCollection(collectionURL: String, headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        RestService.getRequest(collectionURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
                completion(error: error, result: nil)
            }
            else if let jsonResult = result as? Array<NSDictionary> {
                var mail_array = [Mail]()
                for jsonEntry in jsonResult {
                    
                    // May be creating an issue here because I am calling self within the block - make a weak property, use that as the self within the block
                    mail_array.append(self.createMailFromJson(jsonEntry))
                }
                completion(error: nil, result: mail_array)
            }
            else {
                println("Unexpected JSON result while getting mailbox")
            }
        })
    }
    
    class func updateMailCollectionFromNewMail(existingCollection: [Mail], newCollection: [Mail]) -> [Mail] {
        
        //Creating a mutable collection of mail from the existing collection
        var updatedCollection:[Mail] = existingCollection
        
        //Update existing mail
        for mail in newCollection {
            if updatedCollection.filter({$0.id == mail.id}).count > 0 {
                var existingMail:Mail = updatedCollection.filter({$0.id == mail.id}).first!
                var existingIndex:Int = find(updatedCollection, existingMail)!
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
        mailbox = mailbox.sorted { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
        self.appendMailArrayToCoreData(mailArray)
    }
    
    class func updateOutboxAndAppendMailToCache(mailArray: [Mail]) {
        outbox = self.updateMailCollectionFromNewMail(outbox, newCollection: mailArray)
        outbox = outbox.sorted { $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedDescending }
        self.appendMailArrayToCoreData(mailArray)
    }
    
}