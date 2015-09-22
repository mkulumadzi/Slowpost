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
    @NSManaged var toEmails:String
    @NSManaged var attachments:NSSet
    @NSManaged var dateSent:NSDate!
    @NSManaged var scheduledToArrive:NSDate!
    @NSManaged var dateDelivered:NSDate!
    @NSManaged var myStatus:String!
    
    func imageAttachments() -> [ImageAttachment] {
        var imageAttachments:[ImageAttachment]!
        for attachment in attachments.allObjects {
            if let imageAttachment = attachment as? ImageAttachment {
                imageAttachments.append(imageAttachment)
            }
        }
        return imageAttachments
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
    
    func toNames() -> String {
        var names = ""
        var index = 0
        for person in self.toPeople.allObjects {
            if index > 0 {
                names += ", "
            }
            names += "\(person.name)"
            index += 1
        }
        return names
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

}