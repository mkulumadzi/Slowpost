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
    
//    func getImage(completion: (error: NSError?, result: AnyObject?) -> Void) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let dataController = appDelegate.dataController
//        self.currentlyDownloadingImage = true
//        FileService.downloadImage(self.url, completion: { (error, result) -> Void in
//            if let image = result as? UIImage {
//                self.image = image
//                self.currentlyDownloadingImage = false
//                do {
//                    try dataController.moc.save()
//                    completion(error: nil, result: image)
//                } catch {
//                    completion(error: error as NSError, result: nil)
//                }
//            }
//            else {
//                Flurry.logEvent("Failed_To_Download_Image")
//                completion(error: nil, result: "Failure")
//                print("Failed to download image")
//            }
//        })
//    }
    
}

//    class func addImageToCoreDataMail(id: String, image: UIImage, key: String) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//
//        let fetchRequest = NSFetchRequest(entityName: "Mail")
//        let predicate = NSPredicate(format: "id == %@", id)
//        fetchRequest.predicate = predicate
//
//        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
//
//        for object in fetchResults! {
//            object.setValue(UIImagePNGRepresentation(image), forKey: key)
//        }
//
//        var error: NSError?
//        do {
//            try managedContext.save()
//        } catch let error1 as NSError {
//            error = error1
//            print("Error saving person \(error), \(error?.userInfo)")
//        }
//
//    }