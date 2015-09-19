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
    
    @NSManaged  var people: [Person]
    @NSManaged var emails: [String]
    @NSManaged var numUnread: Int
    @NSManaged var numUndelivered: Int
    @NSManaged var personSentMostRecentMail: Bool
    
}