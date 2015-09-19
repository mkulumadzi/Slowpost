//
//  LoggedInUser.swift
//  Slowpost
//
//  Created by Evan Waters on 9/18/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LoggedInUser: Person {
    
    @NSManaged var token:String
    
// May want to implement this, but not doing it yet...
//    func isValid() -> Bool {
//        //To Do:
//        // - check if token has expired
//        // - check if token and user are valid on the server
//        return true
//    }
    
}