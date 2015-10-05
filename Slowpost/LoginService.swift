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
    
    class func getTokenFromKeychain() -> String? {
        if MyKeychainWrapper.myObjectForKey(kSecAttrService) as? String == "postoffice" {
            if let token = MyKeychainWrapper.myObjectForKey("v_Data") as? String {
                var jwt:JWT!
                do {
                    jwt = try decode(token)
                } catch _ {
                    print("Could not decode token")
                }
                if jwt!.expired == false {
                    return token
                }
            }
        }
        return nil
    }
    
    class func saveLoginToUserDefaults(userToken: String) {
        MyKeychainWrapper.mySetObject(userToken, forKey:kSecValueData)
        MyKeychainWrapper.mySetObject("postoffice", forKey:kSecAttrService)
        MyKeychainWrapper.writeToKeychain()
    }
    
    class func confirmTokenMatchesValidUserOnServer(completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        let userId = self.getUserIdFromToken()
        let url = "\(PostOfficeURL)/person/id/\(userId)"
        RestService.getRequest(url, headers: nil, completion: { error, result -> Void in
            if error != nil {
                print("Token does not match valid user")
                completion(error: error, result: nil)
            }
            else {
                print(result)
                completion(error: nil, result: "Success")
            }
        })
    }
    
    class func getUserIdFromToken() -> String {
        let token = self.getTokenFromKeychain()!
        let payload = JSON(self.getTokenPayload(token)!)
        let userId = payload["id"].stringValue
        return userId
    }
    
    class func logIn(parameters: [String: String], completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        
        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
            .responseJSON { (_, response, result) in
                switch result {
                case .Success (let result):
                    let json = JSON(result)
                    let token = json["access_token"].stringValue
                    self.saveLoginToUserDefaults(token)
                    completion(error: nil, result: "Success")
                case .Failure(_, let error):
                    completion(error: error, result: nil)
                }
        }
        
    }
    
    class func getTokenPayload(token: String) -> [String: AnyObject]? {
        var payload:[String: AnyObject]!
        var jwt:JWT!
        do {
            jwt = try decode(token)
        } catch _ {
            print("Could not decode token")
        }
        if jwt != nil {
            payload = jwt!.body
        }
        return payload
    }
    
    class func logOut() {
        Flurry.logEvent("Logged_Out")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        
        // Clear the keychain
        MyKeychainWrapper.mySetObject("", forKey:kSecValueData)
        MyKeychainWrapper.mySetObject("", forKey:kSecAttrService)
        MyKeychainWrapper.writeToKeychain()
        
        // Delete cached objects from Core Data
        dataController.deleteCoreDataObjects("Mail")
        dataController.deleteCoreDataObjects("Person")
        dataController.deleteCoreDataObjects("Conversation")
        dataController.deleteCoreDataObjects("Note")
        dataController.deleteCoreDataObjects("ImageAttachment")
        
    }
    
//    class func decodeTokenAndAttemptLogin(token: String, managedContext: NSManagedObjectContext, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
//        let payload = getTokenPayload(token)
//        if let userId = payload!["id"] as? String {
//            self.updateLoggedInUserFromId(userId, token: token, managedContext: managedContext, completion: { (erorr, result) -> Void in
//                if result as? String == "Success" {
//                    loggedInUserId = userId
//                    loggedInUserToken = token
//                    completion(error: nil, result: "Success")
//                }
//                else {
//                    completion(error: nil, result: "Failure")
//                }
//            })
//        }
//        else {
//            completion(error: nil, result: "Failure")
//        }
//    }
    
    
//    class func decodeToken(token: String) -> JWT? {
//        do {
//            let jwt = try decode(token)
//            return jwt
//        } catch _ {
//            print("Could not decode token")
//        }
//    }
    
    // There are going to be some holes in this for now, with 304 and 404 statuses...
//    class func updateLoggedInUserFromId(userId: String, token: String, managedContext: NSManagedObjectContext, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
//        var headers:[String: String] = ["Authorization": "Bearer \(token)"]
//        if loggedInUser != nil {
//            headers["IF_MODIFIED_SINCE"] = loggedInUser.updatedAt.formattedAsUTCString()
//        }
//
//        let url = "\(PostOfficeURL)/person/id/\(userId)"
//        RestService.getRequest(url, headers: headers, completion: { (error, result) -> Void in
//            if let string = result as? String {
//                var json = JSON(string)
//                json["token"] = JSON(token)
//                self.addOrUpdateCoreDataEntityFromJson(json, object: loggedInUser, managedContext: managedContext)
//                completion(error: nil, result: "Success")
//            }
//            else {
//                completion(error: nil, result: "Failure")
//            }
//        })
//    }
    
//    override class func addOrUpdateCoreDataEntityFromJson(json: JSON, object: NSManagedObject, managedContext: NSManagedObjectContext) {
//        
//        print("Starting to update core data entity")
//        
//        let loggedInUserMoc = object as! LoggedInUser
//        loggedInUserMoc.token = json["token"].stringValue
//        
//        super.addOrUpdateCoreDataEntityFromJson(json, object: loggedInUserMoc, managedContext: managedContext)
//        
//        self.setLoggedInUserGlobalVariable(managedContext)
//    }
    
//    class func addOrUpdateCoreDataEntityFromJson2(json: JSON, object: NSManagedObject) {
//        print("Starting to update core data entity")
//        
//        
////        let managedContext = CoreDataService.initializeManagedContext()
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        
//        let loggedInUserMoc = object as! LoggedInUser
//        loggedInUserMoc.token = json["token"].stringValue
//        loggedInUser.id = json["_id"]["$oid"].stringValue
//        loggedInUser.updatedAt = NSDate(dateString: json["updated_at"].stringValue)
//        loggedInUser.createdAt = NSDate(dateString: json["created_at"].stringValue)
//        
//        do {
//            try managedContext.save()
//        } catch {
//            fatalError("Failure to save context: \(error)")
//        }
//        
////        self.setLoggedInUserGlobalVariable(managedContext)
//    }
    
//    class func getLoggedInUser() -> LoggedInUser {
//        
//        print("Got here!")
//        
//        var loggedInUserFetched:LoggedInUser!
//        let fetchRequest = NSFetchRequest(entityName: "LoggedInUser")
//        fetchRequest.fetchLimit = 1
//        
//        
//        let fetchedResults = CoreDataService.executeFetchRequest2(fetchRequest)
//        if fetchedResults != nil {
//            loggedInUserFetched = fetchedResults![0] as! LoggedInUser
//        }
//        return loggedInUserFetched
//    }

//    class func getUpdatedAtHeader(headers:[String:String]) -> [String: String]? {
//        if loggedInUser != nil {
//            let updatedAt = loggedInUser.updatedAt.formattedAsUTCString()
//            headers["IF_MODIFIED_SINCE"] = updatedAt
//        }
//        return headers
//    }
    
//    class func getLoggedInUser(managedContext: NSManagedObjectContext) -> LoggedInUser? {
//        let fetchRequest = NSFetchRequest(entityName: "LoggedInUser")
//        let loggedInUser = CoreDataService.executeFetchRequest(managedContext, fetchRequest: fetchRequest)![0] as! LoggedInUser
//        return loggedInUser
//    }

    
//    class func logIn(parameters: [String: String], managedContext: NSManagedObjectContext, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
//        
//        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
//            .responseJSON { (_, response, result) in
//                print(response)
//                print(result)
//            switch result {
//            case .Success (let result):
//                if response!.statusCode != 200 {
//                    completion(error: nil, result: response!.statusCode)
//                }
//                else {
//                    let json = JSON(result)
//                    let token = json["access_token"].stringValue
//                    self.saveLoginToUserDefaults(token)
//                    
//                    var loggedInUserJson = json["person"]
//                    loggedInUserJson["token"] = JSON(token)
////                    self.addOrUpdateCoreDataEntityFromJson2(json, object: loggedInUser)
//                    
//                    
//                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                    let managedContext = appDelegate.managedObjectContext!
//                    
//                    
//                    let loggedInUserMoc = NSEntityDescription.insertNewObjectForEntityForName("LoggedInUser", inManagedObjectContext: managedContext) as! LoggedInUser
//
//                    
//                    loggedInUserMoc.token = json["token"].stringValue
//                    loggedInUser.id = json["person"]["_id"]["$oid"].stringValue
//                    loggedInUser.updatedAt = NSDate(dateString: json["person"]["updated_at"].stringValue)
//                    loggedInUser.createdAt = NSDate(dateString: json["person"]["created_at"].stringValue)
//                    
//                    
//                    do {
//                        try managedContext.save()
//                    } catch {
//                        fatalError("Failure to save context: \(error)")
//                    }
//                    
//                    completion(error: nil, result: "Success")
//                }
//            case .Failure(_, let error):
//                print(error)
//                completion(error: nil, result: response!.statusCode)
//            }
//        }
//        
//    }
    
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