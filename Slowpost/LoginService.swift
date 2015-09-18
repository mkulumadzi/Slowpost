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
    
    class func logIn(parameters: [String: String], completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        
        print(parameters)
        
        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
            .responseJSON { (_, response, result) in
                print(response)
                print(result)
            switch result {
            case .Success (let result):
                if response!.statusCode != 200 {
                    completion(error: nil, result: response!.statusCode)
                }
                else {
                    print("\(result)")
                    let json = JSON(result)
                    print(json)
                    userToken = json["access_token"].stringValue
                    self.saveLoginToUserDefaults(userToken)
                    let person:Person! = PersonService.createPersonFromJson(json["person"])
                    loggedInUser = person
                    PersonService.updateLoggedInUserInCoreData(person)
                    completion(error: nil, result: "Success")
                }
            case .Failure(_, let error):
                print(error)
                completion(error: nil, result: response!.statusCode)
            }
        }
        
    }
    
//    class func logIn(parameters: [String: String], completion: (error: ErrorType?, result: AnyObject?) -> Void) {
//        
//        print(parameters)
//        
//        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
//            .response { (request, response, data, error) in
//                if error != nil {
//                    completion(error: error, result: nil)
//                }
//                else if let response: AnyObject = response {
//                    if response.statusCode == 401 {
//                        completion(error: nil, result: response.statusCode)
//                    }
//                }
//            }
//            .responseJSON { (_, response, result) in
//                print(response)
//                print(result)
//                
//                
//                let json = JSON(response!)
//                print(json)
//                userToken = json["access_token"].stringValue
//                self.saveLoginToUserDefaults(userToken)
//                let person:Person! = PersonService.createPersonFromJson(json["person"])
//                loggedInUser = person
//                PersonService.updateLoggedInUserInCoreData(person)
//                completion(error: nil, result: "Success")
//        }
//        
//    }
    
    class func logOut() {
        Flurry.logEvent("Logged_Out")
        
        // Clear the keychain
        MyKeychainWrapper.mySetObject("", forKey:kSecValueData)
        MyKeychainWrapper.mySetObject("", forKey:kSecAttrService)
        MyKeychainWrapper.writeToKeychain()
        
        // Delete cached objects from Core Data
        CoreDataService.deleteCoreDataObjects("Mail")
        CoreDataService.deleteCoreDataObjects("Person")
        CoreDataService.deleteCoreDataObjects("LoggedInUser")
        CoreDataService.deleteCoreDataObjects("ConversationMetadata")
        
        loggedInUser = nil
        
    }
    
    class func checkFieldAvailability(params: [String: String], completion: (error: ErrorType?, result: JSON?) -> Void) {
        let key:String = Array(params.keys)[0]
        let value:String = params[key]!
        
        let availableURL = "\(PostOfficeURL)/available?\(key)=\(value)"
        let headers = ["Authorization": "Bearer \(appToken)"]
        
        RestService.getRequest(availableURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                completion(error: error, result: nil)
            }
            else {
                let json = JSON(result!)
                completion(error: nil, result: json)
            }
        })
    }

}