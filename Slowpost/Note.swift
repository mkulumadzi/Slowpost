//
//  Note.swift
//  Slowpost
//
//  Created by Evan Waters on 9/18/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import Foundation

class Note: Attachment {
    
    var content:String
    
    init(id: String, content:String) {
        self.content = content
        super.init(id: id)
    }
}