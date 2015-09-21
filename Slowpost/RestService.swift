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
        
        print(requestHeaders)
        
//        var requestHeaders = headers
//        if requestHeaders != nil && requestHeaders!["Authorization"] == nil {
//            if requestHeaders != nil {
//                requestHeaders!["Authorization"] = self.addAuthHeader()
//            }
//            else {
//                requestHeaders! = ["Authorization": self.addAuthHeader()]
//            }
//        }
//        else {
//            requestHeaders! = ["Authorization": self.addAuthHeader()]
//        }
        
//        let requestHeaders = ["Authorization": self.addAuthHeader()]
        
        
        Alamofire.request(.GET, requestURL, headers: requestHeaders)
            .responseJSON { (_, response, result) in
                
            print(response)
            print(result)

            print("The response status code is \(response!.statusCode)")
            switch result {
            case .Success (let result):
                if let dataArray = result as? [AnyObject] {
                    completion(error: nil, result: dataArray)
                }
                else {
                    completion(error: nil, result: result)
                }
            case .Failure(_, let error):
                print(error)
                completion(error: nil, result: response!.statusCode)
            }
        }
    }

    class func postRequest(requestURL:String, parameters: [String: AnyObject]?, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        var requestHeaders = headers
        if requestHeaders != nil && requestHeaders!["Authorization"] == nil {
            if requestHeaders != nil {
                requestHeaders!["Authorization"] = self.addAuthHeader()
            }
            else {
                requestHeaders! = ["Authorization": self.addAuthHeader()]
            }
        }
        else {
            requestHeaders! = ["Authorization": self.addAuthHeader()]
        }
        
        
        print("POST to \(requestURL)")
        print(headers)
        lastPostRequest = Alamofire.request(.POST, requestURL, parameters: parameters, headers: headers, encoding: .JSON)
            
            // To Do: Let Alamofire get correct result status (it seems to think that an empty response is a FAILURE
            .validate(statusCode: 200..<300)
            .responseJSON { (_, response, result) in
            if response!.statusCode == 201 {
                completion(error: nil, result: [201, response!.allHeaderFields["Location"] as! String])
            }
            else if response!.statusCode == 204 {
                completion(error: nil, result: [204, ""])
            }
            else {
                //To Do: Capture case where an error message is returned
                
                completion(error: nil, result: "Unexpected result")
            }
        }
    }
    
//    class func postRequest(requestURL:String, parameters: [String: String]?, headers: [String: String]?, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
//        
//        let request_headers:[String: String] = self.addAuthHeader(headers)
//        
//        
//        print("POST to \(requestURL)")
//        print(request_headers)
//        lastPostRequest = Alamofire.request(.POST, requestURL, parameters: parameters, headers: request_headers, encoding: .JSON)
//            .responseJSON { (request, response, result) in
//                
//                print("The response status is \(response!.statusCode)")
//                print("The result is \(result)")
//                let location = response!.allHeaderFields["Location"]
//                print("The location is \(location)")
//                
//                print(request!.allHTTPHeaderFields)
//                print(response)
//                print(result)
//                
//                
//                switch result {
//                case .Success (let data):
//                    if response!.statusCode == 201 {
//                        completion(error: nil, result: [201, response!.allHeaderFields["Location"] as! String])
//                    }
//                    else if response!.statusCode == 204 {
//                        completion(error: nil, result: [204, ""])
//                    }
//                    else {
//                        let json = JSON(data)
//                        let error_message:String? = json["message"].stringValue
//                        if error_message != nil {
//                            completion(error: nil, result: error_message!)
//                        }
//                        else {
//                            completion(error: nil, result: "Unexpected result")
//                        }
//                    }
//                case .Failure(_, let error):
//                    print("Request failed with error: \(error)")
//                }
//        }
//    }
    
            
    
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
    
//    class func sinceHeader(group: [AnyObject]) -> [String: String] {
//        var maxUpdatedAt = ""
//        
//        if let objects = group as? [Mail] {
//            maxUpdatedAt = objects.map{$0.updatedAtString}.maxElement()!
//        }
//        else if let objects = group as? [Person] {
//            maxUpdatedAt = objects.map{$0.updatedAtString}.maxElement()!
//        }
//        else if let objects = group as? [ConversationMetadata] {
//            maxUpdatedAt = objects.map{$0.updatedAtString}.maxElement()!
//        }
//        
//        let headers = ["IF_MODIFIED_SINCE": maxUpdatedAt]
//        
//        return headers
//    }
    
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