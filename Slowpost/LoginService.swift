//
//  DataManager.swift
//  Slowpost
//
//  Created by Evan Waters on 3/25/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import SwiftyJSON

let MyKeychainWrapper = KeychainWrapper()

class LoginService {
    
    class func saveLoginToUserDefaults(userToken: String) {
        MyKeychainWrapper.mySetObject(userToken, forKey:kSecValueData)
        MyKeychainWrapper.mySetObject("postoffice", forKey:kSecAttrService)
        MyKeychainWrapper.writeToKeychain()
    }
    
    class func logIn(parameters: [String: String], completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    if response.statusCode == 401 {
                        completion(error: nil, result: response.statusCode)
                    }
                }
            }
            .responseJSON { (_, _, JSON, error) in
                if let response = JSON as? NSDictionary {
                    userToken = response.valueForKey("access_token") as! String
                    self.saveLoginToUserDefaults(userToken)
                    var person:Person! = PersonService.createPersonFromJson(response.valueForKey("person") as! NSDictionary)
                    loggedInUser = person
                    PersonService.savePersonToCoreData(person)
                    
                    completion(error: nil, result: "Success")
                }
        }
        
    }
    
    class func logOut() {
        Flurry.logEvent("Logged_Out")
        
        // Clear the keychain
        MyKeychainWrapper.mySetObject("", forKey:kSecValueData)
        MyKeychainWrapper.mySetObject("", forKey:kSecAttrService)
        MyKeychainWrapper.writeToKeychain()
        
        // Delete cached objects from Core Data
        CoreDataService.deleteCoreDataObjects("Mail")
        CoreDataService.deleteCoreDataObjects("Person")
        
        loggedInUser = nil
        
    }

}