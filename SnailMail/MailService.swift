//
//  MailService.swift
//  Snailtale
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MailService {
    
    class func createMailFromJson(jsonEntry: NSDictionary) -> Mail {
        
        let id = jsonEntry.objectForKey("_id")!.objectForKey("$oid") as! String
        let status = jsonEntry.objectForKey("status") as! String
        let from = jsonEntry.objectForKey("from") as! String
        let to = jsonEntry.objectForKey("to") as! String
        let content = jsonEntry.objectForKey("content") as! String
        
        let arrivalString = jsonEntry.objectForKey("scheduled_to_arrive") as? String
        let scheduledToArrive = NSDate(dateString: arrivalString!)
        
        let updatedString = jsonEntry.objectForKey("updated_at") as! String
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry.objectForKey("created_at") as! String
        let createdAt = NSDate(dateString: createdString)
        
        
        var mail = Mail(id: id, status: status, from: from, to: to, content: content, image: nil, imageThumb: nil, scheduledToArrive: scheduledToArrive, updatedAt: updatedAt, createdAt: createdAt)
        
        return mail
    }
    
    class func getMailById(id: String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let mailURL = "\(PostOfficeURL)/mail/id/\(id)"
        RestService.getRequest(mailURL, completion: { (error, result) -> Void in
            if error != nil {
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
        let mailImageURL = "\(PostOfficeURL)/mail/id/\(mail.id)/image"
        
        FileService.downloadImage(mailImageURL, completion: { (error, result) -> Void in
            if let image = result as? UIImage {
                mail.image = image
                completion(error: nil, result: mail.image)
            }
            else {
                mail.image = UIImage(named: "Default Card.png")!
                completion(error: nil, result: mail.image)
            }
        })
        
    }

    class func getMailThumbnailImage(mail: Mail, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let mailThumbnailImageURL = "\(PostOfficeURL)/mail/id/\(mail.id)/image?thumb=x69"
        
        FileService.downloadImage(mailThumbnailImageURL, completion: { (error, result) -> Void in
            if let thumbnail = result as? UIImage {
                mail.imageThumb = thumbnail
                completion(error: nil, result: mail.imageThumb)
            }
            else {
                mail.imageThumb = UIImage(named: "Default Card.png")!
                completion(error: nil, result: mail.imageThumb)
            }
        })
    }
    
    
    class func getMailCollection(collectionURL: String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        RestService.getRequest(collectionURL, completion: { (error, result) -> Void in
            if error != nil {
                completion(error: error, result: nil)
            }
            else if let jsonResult = result as? Array<NSDictionary> {
                var mail_array = [Mail]()
                for jsonEntry in jsonResult {
                    mail_array.append(self.createMailFromJson(jsonEntry))
                }
                completion(error: nil, result: mail_array)
            }
            else {
                println("Unexpected JSON result")
            }
        })
    }
    
}