//
//  ImageAttachment.swift
//  Slowpost
//
//  Created by Evan Waters on 9/18/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation

class ImageAttachment: Attachment {
    
    var url:String
    var image:UIImage
    var currentlyDownloadingImage:Bool!
    
    
    init(id: String, url:String, image:UIImage, currentlyDownloadingImage:Bool?) {
        self.url = url
        self.image = image
        self.currentlyDownloadingImage = currentlyDownloadingImage
        super.init(id: id)
    }
}