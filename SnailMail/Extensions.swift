//
//  Extensions.swift
//  SnailMail
//
//  Created by Evan Waters on 6/22/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation

extension NSDate {
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
}

extension Array {
    var last: T {
        return self[self.endIndex - 1]
    }
}