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
    @NSManaged var name:String!
    @NSManaged var origin:String!
    @NSManaged var contactId:String!
    @NSManaged var emails:NSSet!
    @NSManaged var nameLetter:String
    
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
    
    func getLetterFromName(name: String) -> String {
        let firstLetter = String(name.characters.first!)
        let upper = firstLetter.uppercaseString
        let acceptableLetters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        if acceptableLetters.indexOf(upper) != nil {
            return upper
        }
        else {
            return "#"
        }
    }
    
}