//
//  MailCell.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailCell: UITableViewCell {


    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var mailImage: UIImageView!
    
    var mail:Mail!
    var from:Person!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
