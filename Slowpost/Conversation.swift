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
    @NSManaged var emails: String
    @NSManaged var numUnread: Int
    @NSManaged var numUndelivered: Int
    @NSManaged var personSentMostRecentMail: Bool
    
    func peopleNames() -> String {
        var names = ""
        var index = 0
        for person in people {
            if person.id != loggedInUser.id {
                if index > 0 {
                    names += ", "
                }
                names += person.name
                index += 1
            }
        }
        return names
    }
    
}