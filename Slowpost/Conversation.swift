//
//  Conversation.swift
//  Slowpost
//
//  Created by Evan Waters on 9/1/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Conversation: PostofficeObject {
    
    @NSManaged weak var people:NSSet?
    @NSManaged weak var emails: NSSet?
    @NSManaged var numUnread: Int16
    @NSManaged var numUndelivered: Int16
    @NSManaged var personSentMostRecentMail: Bool
    
    func conversationList() -> String {
        var list = ""
        var index = 0
        for item in people!.allObjects {
            let person = item as! Person
            let userId = LoginService.getUserIdFromToken()
            if person.id != userId {
                if index > 0 { list += ", " }
                list += person.fullName()
                index += 1
            }
        }
        for item in emails!.allObjects {
            let emailAddress = item as! EmailAddress
            if index > 0 { list += ", " }
            list += emailAddress.email
            index += 1
        }
        return list
    }
    
}