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
    @NSManaged var currentlyDownloadingImage:Bool
    
    func getImage(managedContext: NSManagedObjectContext, completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        self.currentlyDownloadingImage = true
        FileService.downloadImage(self.url, completion: { (error, result) -> Void in
            if let image = result as? UIImage {
                self.image = image
                self.currentlyDownloadingImage = false
                do {
                    try managedContext.save()
                    completion(error: nil, result: image)
                } catch {
                    completion(error: error as NSError, result: nil)
                }
            }
            else {
                Flurry.logEvent("Failed_To_Download_Image")
                completion(error: nil, result: "Failure")
                print("Failed to download image")
            }
        })
    }
    
}