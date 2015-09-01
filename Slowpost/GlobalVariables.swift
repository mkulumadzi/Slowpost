//
//  GlobalVariables.swift
//  Slowpost
//
//  Created by Evan Waters on 7/29/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import UIKit
import AddressBook
import Alamofire

let PostOfficeURL = ConfigurationService.getPostOfficeURL()
var addressBook:ABAddressBook!
var deviceToken:String!
var loggedInUser:Person!
var mailbox = [Mail]()
var outbox = [Mail]()
var penpals = [Person]()
var conversationMetadataArray = [ConversationMetadata]()
var registeredContacts = [Person]()
var lastPostRequest:Alamofire.Request!

var appToken:String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzY29wZSI6ImNyZWF0ZS1wZXJzb24gcmVzZXQtcGFzc3dvcmQifQ.NTQaqkfCH2ldKXqyKOKgwbTXT8KajBixmsS1vFR9t8a_kz3YIDo6NmcTOQftRxnZ4oMOl9Se7N1-uytIs-oAffIexOD0-fEiEy1IJfEHIK81cEWBPGXoT-au6z7Nf5Lzob2K1l5C5VDYyJh8M7hezNpdFJOA8Tnhp2ANdOCdHqXh3eyJmDw2v13eZWNfi-fM0nUAVA_cbdZcOwiusvHW14KwFq-9OMCeKivSCaWuYKr92Ml1QsO60PN-g6SMx_UDxhub72attZwIgyqmMWiMIquxqZaV9Lz4nnkMoCjRJ08l3yP-Sw-erAAb7wJKTTaUcKs2Q7gAexxx30t7YLrXKw"

var userToken:String!

let screenSize:CGRect = UIScreen.mainScreen().bounds
let screenWidth = screenSize.size.width
let screenHeight = screenSize.size.height

let deviceType = getDeviceType()

func getDeviceType() -> String {
    if UIDevice.currentDevice().modelName != "Simulator" {
        return UIDevice.currentDevice().modelName
    }
    else if screenHeight == 480 {
        return "iPhone 4S"
    }
    else if screenHeight == 568 {
        return "iPhone 5S"
    }
    else if screenHeight == 667 {
        return "iPhone 6"
    }
    else if screenHeight == 960 {
        return "iPhone 6 Plus"
    }
    else {
        return UIDevice.currentDevice().modelName
    }
}