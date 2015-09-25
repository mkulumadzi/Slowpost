//
//  PhoneContactCell.swift
//  Slowpost
//
//  Created by Evan Waters on 9/24/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class PhoneContactCell: UITableViewCell {
    
    var phoneContact:PhoneContact!
    @IBOutlet weak var personNameLabel: UILabel!
    
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
