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
import JWTDecode

let MyKeychainWrapper = KeychainWrapper()

class LoginService: PersonService {
    
    class func saveLoginToUserDefaults(userToken: String) {
        MyKeychainWrapper.mySetObject(userToken, forKey:kSecValueData)
        MyKeychainWrapper.mySetObject("postoffice", forKey:kSecAttrService)
        MyKeychainWrapper.writeToKeychain()
    }
    
    class func decodeTokenAndAttemptLogin(token: String, managedContext: NSManagedObjectContext, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let payload = getTokenPayload(token)
        if let userId = payload!["id"] as? String {
            self.updateLoggedInUserFromId(userId, token: token, managedContext: managedContext, completion: { (erorr, result) -> Void in
                if result as? String == "Success" {
                    completion(error: nil, result: "Success")
                }
                else {
                    completion(error: nil, result: "Failure")
                }
            })
        }
        else {
            completion(error: nil, result: "Failure")
        }
    }
    
    class func getTokenPayload(token: String) -> [String: AnyObject]? {
        var payload:[String: AnyObject]!
        let jwt = decodeToken(token)
        if jwt != nil {
            payload = jwt!.body
        }
        return payload
    }
    
    class func decodeToken(token: String) -> JWT? {
        do {
            let jwt = try decode(token)
            return jwt
        } catch _ {
            print("Could not decode token")
        }
    }
    
    // There are going to be some holes in this for now, with 304 and 404 statuses...
    class func updateLoggedInUserFromId(userId: String, token: String, managedContext: NSManagedObjectContext, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let headers = self.getUpdatedAtHeader()
        let url = "\(PostOfficeURL)/person/id/\(userId)"
        RestService.getRequest(url, headers: headers, completion: { (error, result) -> Void in
            if let string = result as? String {
                var json = JSON(string)
                json["token"] = JSON(token)
                self.addOrUpdateCoreDataEntityFromJson(json, object: loggedInUser, managedContext: managedContext)
                completion(error: nil, result: "Success")
            }
            else {
                completion(error: nil, result: "Failure")
            }
        })
    }
    
    override class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject, managedContext: NSManagedObjectContext) {
        let loggedInUserMoc = object as! LoggedInUser
        loggedInUserMoc.token = json["token"].stringValue
        
        super.addOrUpdateCoreDataEntityFromJson(json, object: loggedInUserMoc, managedContext: managedContext)
        
        self.setLoggedInUserGlobalVariable()
    }
    
    class func setLoggedInUserGlobalVariable() {
        //To Do: Make sure global variable has been set
    }

    class func getUpdatedAtHeader() -> [String: String]? {
        var headers:[String: String]!
        if loggedInUser != nil {
            let updatedAt = loggedInUser.updatedAt.formattedAsUTCString()
            headers = ["IF_MODIFIED_SINCE": updatedAt]
        }
        return headers
    }
    
    class func getLoggedInUser(managedContext: NSManagedObjectContext) -> LoggedInUser? {
        let fetchRequest = NSFetchRequest(entityName: "LoggedInUser")
        let loggedInUser = CoreDataService.executeFetchRequest(managedContext, fetchRequest: fetchRequest)![0] as! LoggedInUser
        return loggedInUser
    }
    
    class func getTokenFromKeychain() -> String? {
        if MyKeychainWrapper.myObjectForKey(kSecAttrService) as? String == "postoffice" {
            if let token = MyKeychainWrapper.myObjectForKey("v_Data") as? String {
                let jwt = decodeToken(token)
                if jwt!.expired == false {
                    return token
                }
            }
        }
        return nil
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
        CoreDataService.deleteCoreDataObjects("LoggedInUser")
        CoreDataService.deleteCoreDataObjects("Conversation")
        CoreDataService.deleteCoreDataObjects("Note")
        CoreDataService.deleteCoreDataObjects("ImageAttachment")
        
        loggedInUser = nil
        
    }
    
    // Mark: Old functions
    
    class func logIn(parameters: [String: String], managedContext: NSManagedObjectContext, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        
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
                    let json = JSON(result)
                    let token = json["access_token"].stringValue
                    self.saveLoginToUserDefaults(token)
                    
                    var loggedInUserJson = json["person"]
                    loggedInUserJson["token"] = JSON(token)
                    self.addOrUpdateCoreDataEntityFromJson(json, object: loggedInUser, managedContext: managedContext)
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