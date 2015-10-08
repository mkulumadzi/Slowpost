//
//  Person.swift
//  Slowpost
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Person: PostofficeObject {
    
    @NSManaged var username:String
    @NSManaged var primaryEmail:String!
    @NSManaged var givenName:String!
    @NSManaged var familyName:String!
    @NSManaged var origin:String!
    @NSManaged var contactId:String!
    @NSManaged var emails:NSSet!
    @NSManaged var nameLetter:String
    
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
    
    func getLetterFromName() -> String {
        var firstLetter:String!
        if familyName != "" {
            firstLetter = String(familyName.characters.first!)
        }
        else if givenName != "" {
            firstLetter = String(givenName.characters.first!)
        }
        else {
            firstLetter = "#"
        }
        
        let upper = firstLetter.uppercaseString
        let acceptableLetters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        if acceptableLetters.indexOf(upper) != nil {
            return upper
        }
        else {
            return "#"
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