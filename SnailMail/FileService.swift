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
    
    class func downloadImage(url: String, completion: (error: NSError?, result: AnyObject?) -> Void) {

        Alamofire.request(.GET, url)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 403 || response.statusCode == 404 {
                        completion(error: nil, result: nil)
                    }
                    else if let image = UIImage(data: data! as NSData) {
                        completion(error: nil, result: image)
                    }
                    else {
                        completion(error: nil, result: nil)
                    }
                }
        }
    }
    
}


