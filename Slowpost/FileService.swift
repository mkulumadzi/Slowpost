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
        
        let token = LoginService.getTokenFromKeychain()!
        let headers:[String: String] = ["Authorization": "Bearer \(token)"]

        print("Getting image at \(url)")
        Alamofire.request(.GET, url, headers: headers)
            .validate(statusCode: 200..<400)
            .responseData { _, response, result in
            print(result)
            print(response)
            switch result {
            case .Success (let result):
                let image = UIImage(data: result as NSData)
                self.postImageDownloadNotification()
                completion(error: nil, result: image)
            case .Failure(_,let error):
                print(error)
                completion(error: nil, result: response!.statusCode)
            }
        }
    }
    
    class func postImageDownloadNotification() {
        let notification = NSNotification(name: "imageDownloaded:", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    class func convertFileNameToNSURL(fileName: String) -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        let path = docURL.URLByAppendingPathComponent(fileName)
        return path
    }
    
    class func saveImageToDocumentDirectory(image: UIImage, fileName: String) -> Bool {
        let path = self.convertFileNameToNSURL(fileName)
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        let success = imageData.writeToURL(path, atomically: true)
        return success
    }
    
    class func getImageFromDocumentDirectory(fileName: String) -> UIImage? {
        let path = self.convertFileNameToNSURL(fileName)
        var image:UIImage!
        if let data = NSData(contentsOfURL: path){
            image = UIImage(data: data)
        }
        return image
    }
    
}


