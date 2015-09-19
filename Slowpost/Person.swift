//
//  Person.swift
//  Slowpost
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation

import UIKit

class Person: PostofficeObject {
    var username:String
    var email:String!
    var name:String!
    var phone:String!
    var address1:String!
    var city:String!
    var state:String!
    var zip:String!
    
    init(id:String, username:String, email:String?, name:String?, phone:String?, address1:String?, city:String?, state:String?, zip:String?, updatedAt:NSDate, updatedAtString:String, createdAt:NSDate) {
        self.username = username
        self.email = email
        self.name = name
        self.phone = phone
        self.address1 = address1
        self.city = city
        self.state = state
        self.zip = zip
        super.init(id: id, updatedAt: updatedAt, updatedAtString: updatedAtString, createdAt: createdAt)
    }
    
    func initials() -> String {
        let splitName = name.characters.split {$0 == " "}.map { String($0) }
        if splitName.count > 1 {
            let firstNameCharacters = Array(splitName[0].characters)
            let firstInitial = firstNameCharacters[0]
            let lastNameCharacters = Array(splitName[splitName.count - 1].characters)
            let lastInitial = lastNameCharacters[0]
            return "\(firstInitial)\(lastInitial)"
        }
        else {
            let nameCharacters = Array(name.characters)
            if nameCharacters.count > 1 {
                return "\(nameCharacters[0])\(nameCharacters[1])"
            }
            else {
                return "\(nameCharacters[0])"
            }
        }
    }
}