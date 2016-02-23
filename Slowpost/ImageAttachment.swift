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
    @NSManaged var fileName:String
    
    func image(completion: (error: NSError?, result: AnyObject?) -> Void) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        var existingImage:UIImage?
        if !fileName.isEmpty && fileName != "" {
            existingImage = FileService.getImageFromDirectory(fileName)
        }
        if let existingImage = existingImage {
            completion(error: nil, result: existingImage)
        }
        else {
            var fileName = getFileNameFromURL()
            // Previously was saving all images with the same filename; this is a temporary workaround to save these with a UUID
            if fileName == "image.jpg" {
                let uuid = NSUUID().UUIDString
                fileName = uuid + ".jpg"
            }
            let image = FileService.getImageFromDirectory(fileName)
            if let image = image {
                self.fileName = fileName
                dataController.save()
                completion(error: nil, result: image)
            }
            else {
                FileService.downloadImage(url, completion: { error, result -> Void in
                    if let image = result as? UIImage {
                        let imageSaved = FileService.saveImageToDirectory(image, fileName: fileName)
                        if imageSaved {
                            self.fileName = fileName
                            dataController.save()
                            completion(error: nil, result: image)
                        }
                        else {
                            dataController.save()
                            completion(error: nil, result: "Failure")
                        }
                    }
                    else {
                        dataController.save()
                        print(error)
                        completion(error: nil, result: nil)
                    }
                })
            }
        }
    }
    
    func getFileNameFromURL() -> String {
        let fileName = url.componentsSeparatedByString("/").last
        return fileName
    }
    
}