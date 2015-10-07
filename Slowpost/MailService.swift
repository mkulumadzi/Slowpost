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
    
    class func updateAllData(completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let userId = LoginService.getUserIdFromToken()
        
        //Update people first
        let peopleURL = "\(PostOfficeURL)person/id/\(userId)/contacts"
        //Using the mail updated date because there is a chance the the user record was updated more recently them some mail that has not been delivered yet, and this mail could include people who have not been loaded yet.
        let peopleHeaders = dataController.getIfModifiedSinceHeaderForEntity("Mail")
        
        RestService.getRequest(peopleURL, headers: peopleHeaders, completion: { (error, result) -> Void in
            if let jsonArray = result as? [AnyObject] {
                print(jsonArray)
                PersonService.appendJsonArrayToCoreData(jsonArray)
                
                //Then update conversations
                let conversationsURL = "\(PostOfficeURL)person/id/\(userId)/conversations"
                let conversationHeaders = dataController.getIfModifiedSinceHeaderForEntity("Conversation")
                RestService.getRequest(conversationsURL, headers: conversationHeaders, completion: { (error, result) -> Void in
                    if let jsonArray = result as? [AnyObject] {
                        print(jsonArray)
                        ConversationService.appendJsonArrayToCoreData(jsonArray)
                        
                        //Then finally update mail
                        let mailURL = "\(PostOfficeURL)person/id/\(userId)/all_mail"
                        let mailHeaders = dataController.getIfModifiedSinceHeaderForEntity("Mail")
                        RestService.getRequest(mailURL, headers: mailHeaders, completion: { (error, result) -> Void in
                            if let jsonArray = result as? [AnyObject] {
                                print("You've got mail")
                                print(jsonArray)
                                self.appendJsonArrayToCoreData(jsonArray)
                                completion(error: nil, result: "Success")
                            }
                            else {
                                completion(error: error, result: nil)
                            }
                        })
                        
                    }
                    else {
                        completion(error: error, result: nil)
                    }
                })
                
            }
            else {
                completion(error: error, result: nil)
            }
        })
    }
    
    class func appendJsonArrayToCoreData(jsonArray: [AnyObject]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let entityName = "Mail"
        for item in jsonArray {
            let json = JSON(item)
            let object = dataController.getCoreDataObjectForJson(json, entityName: entityName)
            self.addOrUpdateCoreDataEntityFromJson(json, object: object)
        }
    }
    
    override class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject) {
        let mail = object as! Mail
        mail.status = json["status"].stringValue
        mail.type = json["type"].stringValue
        self.addConversation(mail, json: json)
        self.addFromPerson(mail, json: json)
        self.addToPeople(mail, json: json)
        self.addEmails(mail, json: json)
        self.addAttachments(mail, json: json)
        
        if json["date_sent"].stringValue != "" {
            mail.dateSent = NSDate(dateString: json["date_sent"].stringValue)
        }
        if json["scheduled_to_arrive"].stringValue != "" {
            mail.scheduledToArrive = NSDate(dateString: json["scheduled_to_arrive"].stringValue)
        }
        if json["date_delivered"].stringValue != "" {
            mail.dateDelivered = NSDate(dateString: json["date_delivered"].stringValue)
        }
        mail.myStatus = json["my_info"]["status"].stringValue
        
        super.addOrUpdateCoreDataEntityFromJson(json, object: mail)
    }
    
    class func addConversation(mail: Mail, json: JSON) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let id = json["conversation_id"].stringValue
        let conversation = dataController.findObjectById(id, entityName: "Conversation") as! Conversation
        mail.conversation = conversation
    }
    
    class func addFromPerson(mail: Mail, json: JSON) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let id = json["from_person_id"].stringValue
        let person = dataController.findObjectById(id, entityName: "Person") as! Person
        mail.fromPerson = person
    }
    
    class func addToPeople(mail: Mail, json: JSON) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let toPeople = mail.mutableSetValueForKey("toPeople")
        for person_id in json["to_people_ids"].arrayValue {
            let id = person_id.stringValue
            let person = dataController.findObjectById(id, entityName: "Person") as! Person
            toPeople.addObject(person)
        }
    }
    
    class func addEmails(mail: Mail, json: JSON) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let emails = mail.mutableSetValueForKey("toEmails")
        for item in json["to_emails"].arrayValue {
            let email = item.stringValue
            let emailAddress = dataController.getCoreDataObject("email == %@", predicateValue: email, entityName: "EmailAddress") as! EmailAddress
            emailAddress.email = email
            emails.addObject(emailAddress)
        }
    }
    
    class func addAttachments(mail: Mail, json: JSON) {
        let attachments = mail.mutableSetValueForKey("attachments")
        for attachment in json["attachments"].arrayValue {
            if attachment["_type"].stringValue == "Postoffice::Note" {
                attachments.addObject(self.addNote(attachment))
            }
            else if attachment["_type"].stringValue == "Postoffice::ImageAttachment" {
                attachments.addObject(self.addImageAttachment(attachment))
            }
        }
    }
    
    class func addNote(json: JSON) -> Note {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let note = dataController.getCoreDataObjectForJson(json, entityName: "Note") as! Note
        note.id = json["_id"]["$oid"].stringValue
        note.content = json["content"].stringValue
        dataController.save()
        return note
    }
    
    class func addImageAttachment(json: JSON) -> ImageAttachment {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let imageAttachment = dataController.getCoreDataObjectForJson(json, entityName: "ImageAttachment") as! ImageAttachment
        imageAttachment.id = json["_id"]["$oid"].stringValue
        imageAttachment.url = json["url"].stringValue
        dataController.save()
        return imageAttachment
    }
    
}