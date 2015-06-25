//
//  SentMailTableViewCell.swift
//  SnailMail
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SentMailTableViewCell: UITableViewCell {
    
    var mail: Mail!
    var person: Person!
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var toName: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mailContent: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let updated = dateFormatter.stringFromDate(mail.updatedAt)
        
        if let name = person?.name {
            toName.text = "To: \(person.name)"
        }
        else {
            toName.text = "To: \(mail.to)"
        }
        
        statusLabel.text = "\(mail.status.capitalizedString) on \(updated)"
        mailContent.text = mail.content
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
