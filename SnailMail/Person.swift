//
//  Person.swift
//  SnailMail
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation

import UIKit

class Person: NSObject {
    var id:String
    var username:String
    var email:String!
    var name:String!
    var phone:String!
    var address1:String!
    var city:String!
    var state:String!
    var zip:String!
    var updatedAt:NSDate
    var createdAt:NSDate
    
    init(id:String, username:String, email:String?, name:String?, phone:String?, address1:String?, city:String?, state:String?, zip:String?, updatedAt:NSDate, createdAt:NSDate) {
        self.id = id
        self.username = username
        self.email = email
        self.name = name
        self.phone = phone
        self.address1 = address1
        self.city = city
        self.state = state
        self.zip = zip
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        super.init()
    }
}