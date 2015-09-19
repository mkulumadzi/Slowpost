//
//  ImageAttachment.swift
//  Slowpost
//
//  Created by Evan Waters on 9/18/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ImageAttachment: Attachment {
    
    @NSManaged var url:String
    @NSManaged var image:UIImage
    @NSManaged var currentlyDownloadingImage:Bool!
    
}