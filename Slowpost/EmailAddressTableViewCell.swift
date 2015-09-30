//
//  EmailAddressTableViewCell.swift
//  Slowpost
//
//  Created by Evan Waters on 9/29/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class EmailAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var emailAddressLabel: UILabel!
    var emailAddress:EmailAddress!
    var checked:Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
