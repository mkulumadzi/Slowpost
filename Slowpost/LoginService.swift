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
        let userId = getUserIdFromToken()
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
        let token = getTokenFromKeychain()!
        let payload = JSON(getTokenPayload(token)!)
        let userId = payload["id"].stringValue
        return userId
    }
    
    class func logIn(parameters: [String: String], completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        print(parameters)
        
        Alamofire.request(.POST, "\(PostOfficeURL)login", parameters: parameters, encoding: .JSON)
            .responseJSON { (response) in
                switch response.result {
                case .Success (let result):
                    let json = JSON(result)
                    let token = json["access_token"].stringValue
                    saveLoginToUserDefaults(token)
                    completion(error: nil, result: "Success")
                case .Failure(let error):
                    if response.response != nil {
                        completion(error: nil, result: "Invalid login")
                    }
                    else {
                        completion(error: error, result: nil)
                    }
                }
        }
        
    }
    
    class func logInWithFacebook(completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                completion(error: error, result: "Failure")
            }
            else {
                let email = result!.valueForKey("email") as! String
                let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let parameters = ["email": "\(email)", "fb_access_token": "\(fbAccessToken)"]
                
                Alamofire.request(.POST, "\(PostOfficeURL)login/facebook", parameters: parameters, encoding: .JSON)
                    .responseJSON { (response) in
                        switch response.result {
                        case .Success (let result):
                            let json = JSON(result)
                            let token = json["access_token"].stringValue
                            saveLoginToUserDefaults(token)
                            completion(error: nil, result: "Success")
                        case .Failure(let error):
                            if response.response != nil {
                                completion(error: nil, result: "Invalid login")
                            }
                            else {
                                completion(error: error, result: nil)
                            }
                        }
                }
            }
        })
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
        dataController.save()
        
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