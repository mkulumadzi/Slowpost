//
//  SearchPersonService.swift
//  Slowpost
//
//  Created by Evan Waters on 10/5/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class SearchPersonService {
    
    class func createSearchPersonFromJson(json: JSON) -> SearchPerson {
        let id = json["_id"]["$oid"].stringValue
        let username = json["username"].stringValue
        let givenName = json["given_name"].stringValue
        let familyName = json["family_name"].stringValue
        let newSearchPerson = SearchPerson(id: id, username: username, givenName: givenName, familyName: familyName)
        return newSearchPerson
    }
    
    class func searchPeople(searchURL: String, completion: (error: ErrorType?, result: AnyObject?) -> Void) {
        RestService.getRequest(searchURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                completion(error: error, result: nil)
            }
            else if let jsonArray = result as? [AnyObject] {
                let searchPeople = self.createPeopleFromJson(jsonArray)
                completion(error: nil, result: searchPeople)
            }
            else {
                print("Unexpected JSON result while getting people")
            }
        })
    }
    
    class func createPeopleFromJson(jsonArray: [AnyObject]) -> [SearchPerson] {
        var searchPeople = [SearchPerson]()
        for item in jsonArray {
            let json = JSON(item)
            if personIsNew(json) == true {
                let searchPerson = self.createSearchPersonFromJson(json)
                searchPeople.append(searchPerson)
            }
        }
        return searchPeople
    }
    
    class func personIsNew(json: JSON) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let fetchRequest = NSFetchRequest(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "id == %@", json["_id"]["$oid"].stringValue)
        let results = dataController.executeFetchRequest(fetchRequest)
        if results!.count == 0 {
            return true
        }
        else {
            return false
        }
    }
    
}
