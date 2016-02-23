//
//  PhoneContactCell.swift
//  Slowpost
//
//  Created by Evan Waters on 9/24/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class PhoneContactCell: UITableViewCell {
    
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var person:Person!
    var emailAddress:EmailAddress!

}
