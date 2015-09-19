//
//  Conversation.swift
//  Slowpost
//
//  Created by Evan Waters on 9/1/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation

import UIKit

class Conversation: PostofficeObject {
    
    var people: [Person]
    var emails: [String]
    var numUnread: Int
    var numUndelivered: Int
    var personSentMostRecentMail: Bool
    
    init(id:String, people:[Person], emails:[String], numUnread:Int, numUndelivered:Int, personSentMostRecentMail:Bool, createdAt:NSDate, updatedAtString:String, updatedAt:NSDate) {
        self.people = people
        self.emails = emails
        self.numUnread = numUnread
        self.numUndelivered = numUndelivered
        self.personSentMostRecentMail = personSentMostRecentMail
        super.init(id: id, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
    }
}