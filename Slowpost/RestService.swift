//
//  RestService.swift
//  Slowpost
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RestService {

    class func getRequest(requestURL:String, headers: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        Alamofire.request(.GET, requestURL, headers: headers)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode != 200 {
                        completion(error: error, result: response.statusCode)
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let response = JSON as? NSDictionary {
                    completion(error: nil, result: response)
                }
                else if let response = JSON as? Array<NSDictionary> {
                    completion(error: nil, result: response)
                }
        }
    }
    
    class func postRequest(requestURL:String, parameters: [String: String]?, completion: (error: NSError?, result: AnyObject?) -> Void) {
        Alamofire.request(.POST, requestURL, parameters: parameters, encoding: .JSON)
            .responseJSON { (request, response, JSON, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 201 {
                        completion(error: nil, result: [201, response.allHeaderFields["Location"] as! String])
                    }
                    else if response.statusCode == 204 {
                        completion(error: nil, result: [204, ""])
                    }
                    else if let response_body = JSON as? NSDictionary {
                        if let error_message = response_body["message"] as? String {
                            completion(error: nil, result: [response.statusCode, error_message])
                        }
                    }
                }
                else {
                    completion(error: nil, result: "Unexpected result")
                }
            }
    }
    
    class func normalizeSearchTerm(term: String) -> String {
        var searchString = ""
        if term.rangeOfString(" ") != nil {
            searchString = term.stringByReplacingOccurrencesOfString(" ", withString: "+")
        }
        else {
            searchString = term
        }
        return searchString
    }
    
    class func sinceHeader(group: [AnyObject]) -> [String: String] {
        var maxUpdatedAt = ""
        
        if let objects = group as? [Mail] {
            maxUpdatedAt = maxElement(objects.map{$0.updatedAtString})
        }
        else if let objects = group as? [Person] {
            maxUpdatedAt = maxElement(objects.map{$0.updatedAtString})
        }
        
        let headers = ["SINCE": maxUpdatedAt]
        
        return headers
    }

}