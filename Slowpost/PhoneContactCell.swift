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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
