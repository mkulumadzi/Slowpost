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
    @NSManaged var fromPersonId:String
    @NSManaged var toPeopleIds:[String]
    @NSManaged var toEmails:[String]
    @NSManaged var attachments:[Attachment]
    @NSManaged var dateSent:NSDate!
    @NSManaged var scheduledToArrive:NSDate!
    @NSManaged var dateDelivered:NSDate!
    @NSManaged var myStatus:String!

}