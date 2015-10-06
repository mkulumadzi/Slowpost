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
        let name = json["name"].stringValue
        let newSearchPerson = SearchPerson(id: id, username: username, name: name)
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
            let searchPerson = self.createSearchPersonFromJson(json)
            searchPeople.append(searchPerson)
        }
        return searchPeople
    }
    
}
