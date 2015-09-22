//
//  Mail.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class Mail: PostofficeObject {
    
    @NSManaged var status:String
    @NSManaged var type:String
    @NSManaged var conversation:Conversation
    @NSManaged var fromPerson:Person
    @NSManaged var toPeople:[Person]
//    @NSManaged var toPeople:[Person]
    @NSManaged var toEmails:String
//    @NSManaged var attachments:[Attachment]
    @NSManaged var attachments:NSSet
    @NSManaged var dateSent:NSDate!
    @NSManaged var scheduledToArrive:NSDate!
    @NSManaged var dateDelivered:NSDate!
    @NSManaged var myStatus:String!
    
//    func image () -> UIImage {
//        var image:UIImage!
//        for attachment in self.attachments {
//            if let imageAttachment = attachment as? ImageAttachment {
//                print("The size of the image is \(imageAttachment.image.size)")
//                print("The image is equal to nil?")
//                if imageAttachment.image.isEqual(nil) {
//                    print("yes")
//                }
//                else {
//                    print("no")
//                }
//                if imageAttachment.image.isEqual(nil) && imageAttachment.currentlyDownloadingImage == false {
//                    imageAttachment.getImage(completion: { (error, result) -> Void in
//                        if let imageReturned = result as? UIImage {
//                            image = imageReturned
//                        }
//                    })
//                }
//                else {
//                    image = imageAttachment.image
//                }
//            }
//        }
////        print(image.size)
////        if image.isEqual(nil) {
////            return UIImage(named: "Default Card.png")!
////        }
////        else {
////            return image
////        }
//        return image
//    }
    
    func content() -> String {
        var content:String!
        for attachment in self.attachments {
            if let note = attachment as? Note {
                content = note.content
            }
        }
        return content
    }
    
    func toNames() -> String {
        var names = ""
        for person in self.toPeople {
            names += "\(person.name) "
        }
        return names
    }
    
    func toLoggedInUser() -> Bool {
        let userId = LoginService.getUserIdFromToken()
        if self.fromPerson.id == userId {
            return false
        }
        else {
            return true
        }
    }

}