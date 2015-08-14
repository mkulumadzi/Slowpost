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

let PostOfficeURL = ConfigurationService.getPostOfficeURL()
var addressBook:ABAddressBook!
var deviceToken:String!
var loggedInUser:Person!
var mailbox = [Mail]()
var outbox = [Mail]()
var penpals = [Person]()
var registeredContacts = [Person]()

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