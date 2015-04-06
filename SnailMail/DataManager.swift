//
//  DataManager.swift
//  SnailMail
//
//  Created by Evan Waters on 3/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation

//URL for Heroku instance of PostOfice server
let PostOfficeURL = "https://safe-ocean-2040.herokuapp.com/"

class DataManager {
    
//    class func getAllMailWithSuccess(success: ((mailData: NSData!) -> Void)) {
//    
//        loadDataFromURL(NSURL(string: "\(PostOfficeURL)/mail")!, completion: {(data,error) -> Void in
//            
//            if let urlData = data {
//                success(mailData: urlData)
//            }
//        })
//    }
    
    class func getMyMailboxWithSuccess(success: ((mailData: NSData!) -> Void)) {
        
        loadDataFromURL(NSURL(string: "\(PostOfficeURL)/person/id/\(loggedInUser.id)/mailbox")!, completion: {(data,error) -> Void in
            
            if let urlData = data {
                success(mailData: urlData)
            }
        })
        
    }
    
    class func getAllPeopleWithSuccess(success: ((peopleData: NSData!) -> Void)) {
        
        loadDataFromURL(NSURL(string: "\(PostOfficeURL)/people")!, completion: {(data,error) -> Void in
            
            if let urlData = data {
                success(peopleData:urlData)
            }
        })
    }
    
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        var session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"com.bigedubs", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        
        loadDataTask.resume()
    }
    

}