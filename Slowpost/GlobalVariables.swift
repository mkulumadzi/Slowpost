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
var lastPostRequest:Alamofire.Request!

var appToken:String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzY29wZSI6ImNyZWF0ZS1wZXJzb24gcmVzZXQtcGFzc3dvcmQifQ.NTQaqkfCH2ldKXqyKOKgwbTXT8KajBixmsS1vFR9t8a_kz3YIDo6NmcTOQftRxnZ4oMOl9Se7N1-uytIs-oAffIexOD0-fEiEy1IJfEHIK81cEWBPGXoT-au6z7Nf5Lzob2K1l5C5VDYyJh8M7hezNpdFJOA8Tnhp2ANdOCdHqXh3eyJmDw2v13eZWNfi-fM0nUAVA_cbdZcOwiusvHW14KwFq-9OMCeKivSCaWuYKr92Ml1QsO60PN-g6SMx_UDxhub72attZwIgyqmMWiMIquxqZaV9Lz4nnkMoCjRJ08l3yP-Sw-erAAb7wJKTTaUcKs2Q7gAexxx30t7YLrXKw"

//var userToken:String!

let screenSize:CGRect = UIScreen.mainScreen().bounds
let screenWidth = screenSize.size.width
let screenHeight = screenSize.size.height

//Colors
let slowpostGreen = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
let slowpostDarkGreen = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
let slowpostDarkGrey = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
let slowpostLightGrey = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
let slowpostYellow = UIColor(red: 255/255, green: 233/255, blue: 62/255, alpha: 1.0)

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