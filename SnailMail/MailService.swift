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
        let image = jsonEntry.objectForKey("image") as? String
        
        let arrivalString = jsonEntry.objectForKey("scheduled_to_arrive") as? String
        let scheduledToArrive = NSDate(dateString: arrivalString!)
        
        let updatedString = jsonEntry.objectForKey("updated_at") as! String
        let updatedAt = NSDate(dateString: updatedString)
        
        let createdString = jsonEntry.objectForKey("created_at") as! String
        let createdAt = NSDate(dateString: createdString)
        
        
        var new_mail = Mail(id: id, status: status, from: from, to: to, content: content, image: image, scheduledToArrive: scheduledToArrive, updatedAt: updatedAt, createdAt: createdAt)
        
        return new_mail
    }
    
    class func getMyMailbox( completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let mailboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/mailbox"
        
        Alamofire.request(.GET, mailboxURL)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 404 {
                        completion(error: error, result: response.statusCode)
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let jsonResult = JSON as? Array<NSDictionary> {
                    var mail_array = [Mail]()
                    for jsonEntry in jsonResult {
                        mail_array.append(self.createMailFromJson(jsonEntry))
                    }
                    completion(error: nil, result: mail_array)
                }
                else {
                    println("Unexpected JSON result for \(mailboxURL)")
                }
        }
    }
    
    class func getMyOutbox( completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let outboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/outbox"
        
        Alamofire.request(.GET, outboxURL)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 404 {
                        completion(error: error, result: response.statusCode)
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let jsonResult = JSON as? Array<NSDictionary> {
                    var mail_array = [Mail]()
                    for jsonEntry in jsonResult {
                        mail_array.append(self.createMailFromJson(jsonEntry))
                    }
                    completion(error: nil, result: mail_array)
                }
                else {
                    println("Unexpected JSON result for \(outboxURL)")
                }
        }
    }
    
    class func readMail(mail: Mail, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let readMailURL = "\(PostOfficeURL)/mail/id/\(mail.id)/read"
        
        Alamofire.request(.POST, readMailURL)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 204 {
                        completion(error: nil, result: "Mail read")
                    }
                }
        }
        
    }
    
    class func getMailById(id: String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let mailURL = "\(PostOfficeURL)/mail/id/\(id)"
        
        Alamofire.request(.GET, mailURL)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 404 {
                        completion(error: error, result: response.statusCode)
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let jsonResult = JSON as? NSDictionary {
                    var mail = self.createMailFromJson(jsonResult)
                    completion(error: nil, result: mail)
                }
                else {
                    println("Unexpected JSON result for \(mailURL)")
                }
        }
    }
    
    class func sendMailToPostoffice(parameters: [String: String], completion: (error: NSError?, result: AnyObject?) -> Void) {

        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"

        Alamofire.request(.POST, sendMailEndpoint, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    completion(error: nil, result: response)
                }
        }
    }

    
}