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
        if fileName != "" {
            let image = FileService.getImageFromDocumentDirectory(fileName)
            completion(error: nil, result: image)
        }
        else {
            FileService.downloadImage(url, completion: { error, result -> Void in
                if let image = result as? UIImage {
                    let fileName = "foo"
                    let imageSaved = FileService.saveImageToDocumentDirectory(image, fileName: fileName)
                    if imageSaved {
                        completion(error: nil, result: image)
                    }
                    else {
                        completion(error: nil, result: "Failure")
                    }
                }
                else {
                    print(error)
                    completion(error: nil, result: nil)
                }
            })
        }
    }
    
}