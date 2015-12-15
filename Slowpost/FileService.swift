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
        
        resizeImage(image, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else if let contextImage = result as? UIImage {
                
                let base64String = encodeImageAsBase64String(contextImage)
                let parameters = ["file": base64String, "filename": filename]
                
                RestService.postRequest(uploadURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
                    if error != nil {
                        print("Got error")
                        completion(error: error, result: nil)
                    }
                    if let response = result as? [AnyObject] {
                        if let location = response[1] as? String {
                            print("Uploaded image!")
                            completion(error: nil, result: location)
                        }
                        else {
                            print("Got an unexpected result")
                            completion(error: nil, result: nil)
                        }
                    }
                    else {
                        print("Something else happened")
                        completion(error: nil, result: nil)
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
        
        let token = LoginService.getTokenFromKeychain()!
        let headers:[String: String] = ["Authorization": "Bearer \(token)"]

        print("Getting image at \(url)")
        Alamofire.request(.GET, url, headers: headers)
            .validate(statusCode: 200..<400)
            .responseData { response in
            switch response.result {
            case .Success (let result):
                let image = UIImage(data: result as NSData)
                postImageDownloadNotification()
                completion(error: nil, result: image)
            case .Failure(let error):
                var statusCode:Int!
                if response.response != nil {
                    statusCode = response.response!.statusCode
                }
                completion(error: error, result: statusCode)
            }
        }
    }
    
    class func postImageDownloadNotification() {
        let notification = NSNotification(name: "imageDownloaded:", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    class func convertFileNameToNSURL(fileName: String) -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        let path = docURL.URLByAppendingPathComponent(fileName)
        return path
    }
    
    class func saveImageToDirectory(image: UIImage, fileName: String) -> Bool {
        let path = convertFileNameToNSURL(fileName)
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        let success = imageData.writeToURL(path, atomically: true)
        return success
    }
    
    class func savePNGToDirectory(image: UIImage, fileName: String) -> Bool {
        let path = convertFileNameToNSURL(fileName)
        let imageData = UIImagePNGRepresentation(image)!
        let success = imageData.writeToURL(path, atomically: true)
        return success
    }
    
    class func getImageFromDirectory(fileName: String) -> UIImage? {
        let path = convertFileNameToNSURL(fileName)
        var image:UIImage?
        if let data = NSData(contentsOfURL: path){
            image = UIImage(data: data)
        }
        return image
    }
    
}


