//
//  MailCell.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailCell: UITableViewCell {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var deliveredLabel: UILabel!
    @IBOutlet weak var mailImage: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var fromViewInitials: UILabel!
    @IBOutlet weak var statusIndicator: UIView!
    
    var mail:Mail!
    var imageFile:UIImage!

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 5
        fromView.layer.cornerRadius = 15
        statusIndicator.layer.cornerRadius = 6
    }

}
