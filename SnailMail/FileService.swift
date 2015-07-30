//
//  FileService.swift
//  Snailtale
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

class FileService {

    class func uploadImage(image:UIImage, filename:String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        let uploadURL = "\(PostOfficeURL)upload"
        var imageData = UIImagePNGRepresentation(image)
        
        let base64String = imageData.base64EncodedStringWithOptions(.allZeros)
        
        let parameters = ["file": base64String, "filename": filename]
        
        RestService.postRequest(uploadURL, parameters: parameters, completion: { (error, result) -> Void in
            if error != nil {
                completion(error: error, result: nil)
            }
            if let response = result as? [AnyObject] {
                if let location = response[1] as? String {
                    completion(error: nil, result: location)
                }
            }
        })
    }

//    //To Do: Test this out:
//    class func actuallyUploadImage(imageName:String, ext:String, completion: (error: NSError?, result: AnyObject?) -> Void) {
//        
//        let uploadURL = "\(PostOfficeURL)upload"
//        let fileURL = NSBundle.mainBundle().URLForResource(imageName, withExtension: ext)
//        
//        Alamofire.upload(.POST, uploadURL, file: fileURL!)
//    }

    
}


