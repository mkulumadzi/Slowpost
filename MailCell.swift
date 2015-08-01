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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mailImage: UIImageView!
    
    var mail:Mail!
    var from:Person!
    var row:Int!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func formatCell() {
        getPerson(mail)
        setStyleBasedOnMailStatus()
        getImage(mail)
        setStatusLabel()
    }
    
    func getPerson(mail: Mail) {
        
        if let person = find(penpals.map({ $0.username }), mail.from) {
            self.from = penpals[person]
            self.fromLabel.text = "From: \(penpals[person].name)"
        }
        else {
            self.fromLabel.text = "From: \(mail.from)"
        }
        
    }
    
    func setStyleBasedOnMailStatus() {
        switch mail.status {
            case "DELIVERED":
                fromLabel.textColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1.0)
            default:
                fromLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
        }
    }
    
    func getImage(mail: Mail) {
        if mail.image != nil {
            mailImage.image = mail.image
        }
        else {
            MailService.getMailImage(mail, completion: { (error, result) -> Void in
                if let image = result as? UIImage {
                    self.mailImage.image = image
                }
                else {
                    self.mailImage.image = UIImage(named: "Default Card.png")!
                }
            })
        }
    }
    
    func setStatusLabel() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        statusLabel.text = "\(mail.status) on \(dateFormatter.stringFromDate(mail.updatedAt))"
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
