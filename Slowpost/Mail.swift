//
//  Mail.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class Mail: PostofficeObject {
    
    @NSManaged var status:String
    @NSManaged var type:String
    @NSManaged var conversation:Conversation
    @NSManaged var fromPerson:Person
    @NSManaged var toPeople:NSSet
    @NSManaged var toEmails:NSSet
    @NSManaged var attachments:NSSet
    @NSManaged var dateSent:NSDate!
    @NSManaged var scheduledToArrive:NSDate!
    @NSManaged var dateDelivered:NSDate!
    @NSManaged var myStatus:String!
    
    func getImage(completion: (error: ErrorType?, result: AnyObject?) -> Void ) {
        var mailImageAttachment:ImageAttachment!
        for attachment in attachments.allObjects {
            if let imageAttachment = attachment as? ImageAttachment {
                mailImageAttachment = imageAttachment
            }
        }
        if mailImageAttachment != nil {
            mailImageAttachment.image({error, result -> Void in
                if let image = result as? UIImage {
                    completion(error: nil, result: image)
                }
                else {
                    print("Error getting image for mail")
                    let image = UIImage(named: "Default Card.png")
                    completion(error: nil, result: image)
                }
            })
        }
        else {
            let image = UIImage(named: "Default Card.png")
            completion(error: nil, result: image)
        }
    }
    
    func content() -> String {
        var content:String!
        for attachment in self.attachments {
            if let note = attachment as? Note {
                content = note.content
            }
        }
        return content
    }
    
    func toList() -> String {
        var list = ""
        var index = 0
        for item in self.toPeople.allObjects {
            let person = item as! Person
            if index > 0 {
                list += ", "
            }
            list += "\(person.fullName())"
            index += 1
        }
        for item in self.toEmails.allObjects {
            let emailAddress = item as! EmailAddress
            if index > 0 { list += ", " }
            list += emailAddress.email
            index += 1
        }
        return list
    }
    
    func toLoggedInUser() -> Bool {
        let userId = LoginService.getUserIdFromToken()
        if self.fromPerson.id == userId {
            return false
        }
        else {
            return true
        }
    }
    
    func markAsRead() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        self.myStatus = "READ"
        dataController.save()
    }

}