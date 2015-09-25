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
    @NSManaged var currentlyDownloadingImage:Bool
    
    func image(completion: (error: NSError?, result: AnyObject?) -> Void) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        print(self)
        if !fileName.isEmpty && fileName != "" {
            let image = FileService.getImageFromDocumentDirectory(fileName)!
            completion(error: nil, result: image)
        }
        else {
            let fileName = self.getFileNameFromURL()
            let image = FileService.getImageFromDocumentDirectory(fileName)
            if image != nil {
                self.fileName = fileName
                dataController.save()
                completion(error: nil, result: image)
            }
            else if currentlyDownloadingImage == false {
                currentlyDownloadingImage = true
                dataController.save()
                FileService.downloadImage(url, completion: { error, result -> Void in
                    if let image = result as? UIImage {
                        let imageSaved = FileService.saveImageToDocumentDirectory(image, fileName: fileName)
                        if imageSaved {
                            self.fileName = fileName
                            self.currentlyDownloadingImage = false
                            dataController.save()
                            completion(error: nil, result: image)
                        }
                        else {
                            self.currentlyDownloadingImage = false
                            dataController.save()
                            completion(error: nil, result: "Failure")
                        }
                    }
                    else {
                        self.currentlyDownloadingImage = false
                        dataController.save()
                        print(error)
                        completion(error: nil, result: nil)
                    }
                })
            }
            else {
                completion(error: nil, result: nil)
            }
        }
    }
    
    func getFileNameFromURL() -> String {
        let fileName = url.componentsSeparatedByString("/").last
        return fileName
    }
    
}