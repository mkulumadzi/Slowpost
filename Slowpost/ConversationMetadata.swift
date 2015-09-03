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
    var numUndelivered:Int
    var updatedAt:NSDate
    var updatedAtString:String
    var mostRecentStatus:String
    var mostRecentSender:String
    
    init(username:String, name:String?, numUnread:Int, numUndelivered:Int, updatedAt:NSDate, updatedAtString:String, mostRecentStatus:String, mostRecentSender:String) {
        self.username = username
        self.name = name
        self.numUnread = numUnread
        self.numUndelivered = numUndelivered
        self.updatedAt = updatedAt
        self.updatedAtString = updatedAtString
        self.mostRecentStatus = mostRecentStatus
        self.mostRecentSender = mostRecentSender
        super.init()
    }
}