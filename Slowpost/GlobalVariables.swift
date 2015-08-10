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
let height = screenSize.size.height