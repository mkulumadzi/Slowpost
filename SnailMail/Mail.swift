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
    var content:String!
    var image:UIImage!
    var imageThumb:UIImage!
    var scheduledToArrive:NSDate!
    var updatedAt:NSDate
    var updatedAtString:String
    var createdAt:NSDate
    
    init(id:String, status:String, from:String, to:String, content:String?, image:UIImage?, imageThumb: UIImage?, scheduledToArrive:NSDate?, updatedAt:NSDate, updatedAtString:String, createdAt:NSDate) {
        self.id = id
        self.status = status
        self.from = from
        self.to = to
        self.content = content
        self.image = image
        self.imageThumb = imageThumb
        self.scheduledToArrive = scheduledToArrive
        self.updatedAt = updatedAt
        self.updatedAtString = updatedAtString
        self.createdAt = createdAt
        super.init()
    }
}