//
//  SentMailTableViewCell.swift
//  SnailMail
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SentMailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var toName: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var mail: Mail!
    var person: Person!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func formatCell() {
        setStatusLabel()
        formatName()
        cardImage.image = mail.imageThumb
//        getImage(mail)
    }
    
//    func getImage(mail: Mail) {
//        if mail.imageThumb != nil {
//            cardImage.image = mail.imageThumb
//        }
//        else {
//            MailService.getMailThumbnailImage(mail, completion: { (error, result) -> Void in
//                if let thumbnail = result as? UIImage {
//                    self.cardImage.image = thumbnail
//                }
//                else {
//                    self.cardImage.image = UIImage(named: "Default Card.png")!
//                }
//            })
//        }
//    }
    
    func formatName() {
        if let name = person?.name {
            toName.text = "To: \(person.name)"
        }
        else {
            toName.text = "To: \(mail.to)"
        }
    }
    
    func setStatusLabel() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let updated = dateFormatter.stringFromDate(mail.updatedAt)
        
        statusLabel.text = "\(mail.status.capitalizedString) on \(updated)"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    

}
