//
//  PostofficeObject.swift
//  Slowpost
//
//  Created by Evan Waters on 9/18/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation

class PostofficeObject: NSObject {
    
    var id:String
    var updatedAt:NSDate
    var updatedAtString:String
    var createdAt:NSDate
    
    init(id:String, updatedAt:NSDate, updatedAtString:String, createdAt:NSDate) {
        self.id = id
        self.updatedAt = updatedAt
        self.updatedAtString = updatedAtString
        self.createdAt = createdAt
        super.init()
    }
    
}