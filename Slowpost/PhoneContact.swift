//
//  PhoneContact.swift
//  Slowpost
//
//  Created by Evan Waters on 9/24/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhoneContact: NSManagedObject {
    
    @NSManaged var id:String
    @NSManaged var name:String
    @NSManaged var emails:NSSet
    @NSManaged var postofficeId:String
    
}
