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
    var name:String!
    
    init(id:String, username:String, name:String?) {
        self.id = id
        self.username = username
        self.name = name
        super.init()
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