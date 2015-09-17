//
//  ConfigurationService.swift
//  Slowpost
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import CoreData

class ConfigurationService {
    
    class func getCurrentConfiguration() -> String {
        var myDict: NSDictionary?
        var currentConfiguration = ""
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            currentConfiguration = dict["Configuration"] as! String
        }
        
        return currentConfiguration
    }
    
    class func getPostOfficeURL() -> String {
        var myDict: NSDictionary?
        let currentConfiguration = getCurrentConfiguration()
        var postOfficeURL = ""
        
        if let path = NSBundle.mainBundle().pathForResource("Configurations", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            let configDict: NSDictionary = (dict[currentConfiguration] as? NSDictionary)!
            postOfficeURL = configDict["PostOfficeURL"] as! String
        }
        
        return postOfficeURL
    }

}
