//
//  ConversationMailCell.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationMailCell: UITableViewCell {

    @IBOutlet weak var mailImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var mailStatusLabel: UIView!
    
    @IBOutlet weak var leadingSpaceToFromView: NSLayoutConstraint!
    @IBOutlet weak var trailingSpaceFromFromView: NSLayoutConstraint!
    
    @IBOutlet weak var leadingSpaceToCardView: NSLayoutConstraint!
    @IBOutlet weak var trailingSpaceFromCardView: NSLayoutConstraint!
    
    var mail:Mail!
    var row:Int!
    var imageFile:UIImage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fromView.layer.cornerRadius = 15
        cardView.layer.cornerRadius = 5
        mailStatusLabel.layer.cornerRadius = 6
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
