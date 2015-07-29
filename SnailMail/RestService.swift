//
//  RestService.swift
//  Snailtale
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RestService {

    class func getRequest(requestURL:String, completion: (error: NSError?, result: AnyObject?) -> Void) {
        Alamofire.request(.GET, requestURL)
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
        }
    }

}