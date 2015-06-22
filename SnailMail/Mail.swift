//
//  Mail.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class Mail: NSObject {
    
    var id:String
    var status:String
    var from:String
    var to:String
    var content:String
    var image:String!
    var scheduledToArrive:NSDate!
    var updatedAt:NSDate
    var createdAt:NSDate
    
    init(id:String, status:String, from:String, to:String, content:String, image:String?, scheduledToArrive:NSDate?, updatedAt:NSDate, createdAt:NSDate) {
        self.id = id
        self.status = status
        self.from = from
        self.to = to
        self.content = content
        self.image = image
        self.scheduledToArrive = scheduledToArrive
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        super.init()
    }
}