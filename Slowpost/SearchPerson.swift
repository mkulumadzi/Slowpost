//
//  SearchPerson.swift
//  Slowpost
//
//  Created by Evan Waters on 10/5/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import UIKit

class SearchPerson: NSObject {
    var id:String
    var username:String
    var givenName:String!
    var familyName:String!
    
    init(id:String, username:String, givenName:String?, familyName: String?) {
        self.id = id
        self.username = username
        self.givenName = givenName
        self.familyName = familyName
        super.init()
    }
    
    func initials() -> String {
        if givenName != "" && familyName != "" {
            return "\(givenName.characters.first!)\(familyName.characters.first!)"
        }
        else if givenName != "" {
            return "\(givenName.characters.first!)"
        }
        else if familyName != "" {
            return "\(familyName.characters.first!)"
        }
        else {
            return ""
        }
    }
    
    func fullName() -> String {
        if givenName != "" && familyName != "" {
            return "\(givenName) \(familyName)"
        }
        else if givenName != "" {
            return givenName
        }
        else {
            return familyName
        }
    }
}