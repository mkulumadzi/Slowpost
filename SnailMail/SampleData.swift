//
//  SampleData.swift
//  SnailMail
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation

//Set up sample data

let personData = [
    Person(id: "1", username:"ewaters", name: "Evan Waters", address1: "121 W 3rd Street", city: "New York", state: "NY", zip: "10012"),
    Person(id: "2", username:"nwaters", name: "Neal Waters", address1: "123 Main Street", city: "New York", state: "NY", zip: "10012"),
    Person(id: "3", username:"cmurray", name: "Catherine Murray", address1: "123 Main Street", city: "New York", state: "NY", zip: "10012")
]

let mailData = [
    Mail(id: "1", from: "bigedubs", to: "nwaters", content: "What's up Neal?"),
    Mail(id: "2", from: "nwaters", to: "bigedubs", content: "Not much, how are you?"),
    Mail(id: "3", from: "nwaters", to: "bigedubs", content: "Want to watch the game?")
]
