//
//  FileService.swift
//  Slowpost
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

let defaultImageSize:CGSize = CGSize(width: 768.0, height: 577.0)

class FileService {

    class func uploadImage(image:UIImage, filename:String, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let uploadURL = "\(PostOfficeURL)upload"
        
        self.resizeImage(image, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else if let contextImage = result as? UIImage {
                
                let base64String = self.encodeImageAsBase64String(contextImage)
                let parameters = ["file": base64String, "filename": filename]
                
                RestService.postRequest(uploadURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
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
        })
    }

    
    class func resizeImage(image: UIImage, completion: (error: NSError?, result: AnyObject?) -> Void) {
            image.resize(defaultImageSize, completionHandler: {(resizedImage, data) -> () in
                completion(error: nil, result: resizedImage)
            })
    }
    
    class func encodeImageAsBase64String(image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let base64String = imageData!.base64EncodedStringWithOptions([])
        return base64String
    }
    
    class func downloadImage(url: String, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        
        let headers:[String: String] = ["Authorization": "Bearer \(userToken)"]

        print("Getting image at \(url)")
        Alamofire.request(.GET, url, headers: headers)
            .response { (request, response, data, error) in
                if error != nil {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 403 || response.statusCode == 404 {
                        completion(error: nil, result: nil)
                    }
                    else if let image = UIImage(data: data! as NSData) {
                        self.postImageDownloadNotification()
                        completion(error: nil, result: image)
                    }
                    else {
                        completion(error: nil, result: nil)
                    }
                }
        }
    }
    
    class func postImageDownloadNotification() {
        let notification = NSNotification(name: "imageDownloaded:", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
}


