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
import CoreData

class RestService {

    class func getRequest(requestURL:String, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        Flurry.logEvent("GET_Request", withParameters: ["URL": "\(requestURL)", "Headers": "\(headers)"])
        
        var requestHeaders:[String: String]!
        if headers != nil {
            requestHeaders = headers
        }
        else {
            requestHeaders = [String: String]()
        }
        
        if requestHeaders["Authorization"] == nil {
            requestHeaders["Authorization"] = self.addAuthHeader()
        }
        
        print(requestURL)   
        print(requestHeaders)
        
        Alamofire.request(.GET, requestURL, headers: requestHeaders)
            .responseJSON { (response) in
            switch response.result {
            case .Success (let result):
                if let dataArray = result as? [AnyObject] {
                    completion(error: nil, result: dataArray)
                }
                else {
                    completion(error: nil, result: result)
                }
            case .Failure(let error):
                var statusCode:Int!
                if response.response != nil {
                    statusCode = response.response!.statusCode
                }
                completion(error: error, result: statusCode)
            }
        }
    }

    class func postRequest(requestURL:String, parameters: [String: AnyObject]?, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        var requestHeaders:[String: String]!
        if headers != nil {
            requestHeaders = headers
        }
        else {
            requestHeaders = [String: String]()
        }
        
        if requestHeaders["Authorization"] == nil {
            requestHeaders["Authorization"] = self.addAuthHeader()
        }
        
        print(requestHeaders)
        
        
        print("POST to \(requestURL)")
        print(headers)
        lastPostRequest = Alamofire.request(.POST, requestURL, parameters: parameters, headers: requestHeaders, encoding: .JSON)
            
            // To Do: Let Alamofire get correct result status (it seems to think that an empty response is a FAILURE
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            var statusCode:Int!
            if response.response != nil {
                statusCode = response.response!.statusCode
            }
            if statusCode != nil {
                if statusCode == 201 {
                    completion(error: nil, result: [201, response.response!.allHeaderFields["Location"] as! String])
                }
                else if statusCode == 204 {
                    completion(error: nil, result: [204, ""])
                }
                else {
                    //To Do: Capture case where an error message is returned
                    completion(error: nil, result: "Unexpected result")
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
    
    class func addAuthHeader() -> String {
        let token = LoginService.getTokenFromKeychain()!
        let auth = "Bearer \(token)"
        return auth
    }
    
    class func endpointForLastPostRequest() -> String? {
        if lastPostRequest != nil {
            let descriptionArray = lastPostRequest.description.characters.split {$0 == " "}.map { String($0) }
            let url = descriptionArray[1]
            let urlArray = url.characters.split {$0 == "/"}.map { String($0) }
            let endpoint:String? = urlArray.last
            return endpoint
        }
        else {
            return nil
        }
    }

}