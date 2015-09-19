//
//  PostofficeObject.swift
//  Slowpost
//
//  Created by Evan Waters on 9/18/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PostofficeObject: NSManagedObject {
    
    @NSManaged var id:String
    @NSManaged var updatedAt:NSDate
    @NSManaged var createdAt:NSDate
    
}