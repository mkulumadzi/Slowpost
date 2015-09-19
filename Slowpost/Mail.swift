//
//  Mail.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class Mail: PostofficeObject {
    
    var status:String
    var type:String
    var fromPersonId:String
    var toPeopleIds:[String]
    var toEmails:[String]
    var attachments:[Attachment]
    var dateSent:NSDate!
    var scheduledToArrive:NSDate!
    var dateDelivered:NSDate!
    var myStatus:String!
    
    init(id:String, status:String, type:String, fromPersonId:String, toPeopleIds:[String], toEmails: [String], attachments:[Attachment], dateSent:NSDate?, scheduledToArrive:NSDate?, dateDelivered:NSDate?, myStatus:String?, updatedAt:NSDate, updatedAtString:String, createdAt:NSDate) {
        self.status = status
        self.type = type
        self.fromPersonId = fromPersonId
        self.toPeopleIds = toPeopleIds
        self.toEmails = toEmails
        self.attachments = attachments
        self.dateSent = dateSent
        self.scheduledToArrive = scheduledToArrive
        self.dateDelivered = dateDelivered
        self.myStatus = myStatus
        super.init(id: id, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
    }
}