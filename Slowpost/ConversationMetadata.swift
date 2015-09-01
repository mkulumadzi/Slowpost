//
//  ConversationMetadata.swift
//  Slowpost
//
//  Created by Evan Waters on 9/1/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation

import UIKit

class ConversationMetadata: NSObject {
    var username:String
    var name:String!
    var numUnread:Int
    var updatedAt:NSDate
    var updatedAtString:String
    
    init(username:String, name:String?, numUnread:Int, updatedAt:NSDate, updatedAtString:String) {
        self.username = username
        self.name = name
        self.numUnread = numUnread
        self.updatedAt = updatedAt
        self.updatedAtString = updatedAtString
        super.init()
    }
}