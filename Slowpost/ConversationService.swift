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
    
    class func appendJsonArrayToCoreData(jsonArray: [AnyObject]) {
        let entityName = "Conversation"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        for item in jsonArray {
            let json = JSON(item)
            let object = dataController.getCoreDataObjectForJson(json, entityName: entityName)
            addOrUpdateCoreDataEntityFromJson(json, object: object)
        }
    }
    
    override class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject) {
        let conversation = object as! Conversation
        addPeople(conversation, json: json)
        addEmails(conversation, json: json)
        conversation.numUnread = json["num_unread"].int16Value
        conversation.numUndelivered = json["num_undelivered"].int16Value
        conversation.personSentMostRecentMail = json["person_sent_most_recent_mail"].boolValue
        
        super.addOrUpdateCoreDataEntityFromJson(json, object: conversation)
    }
    
    class func addPeople(conversation: Conversation, json: JSON) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let conversationPeople = conversation.mutableSetValueForKey("people")
        for person_id in json["people"].arrayValue {
            let id = person_id["$oid"].stringValue
            let person = dataController.findObjectById(id, entityName: "Person") as! Person
            conversationPeople.addObject(person)
        }
    }
    
    class func addEmails(conversation: Conversation, json: JSON) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let emails = conversation.mutableSetValueForKey("emails")
        for item in json["emails"].arrayValue {
            let email = item.stringValue
            let emailAddress = dataController.getCoreDataObject("email == %@", predicateValue: email, entityName: "EmailAddress") as! EmailAddress
            emailAddress.email = email
            emails.addObject(emailAddress)
        }
    }
    
}