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
    @IBOutlet weak var arrivalLabel: UILabel!
    
    var mail:Mail!
    var from:Person!
    var row:Int!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func formatCell() {
        getPerson(mail)
        setStyleBasedOnMailStatus()
        mailImage.image = getImage(mail)
        setStatusLabel()
    }
    
    func getPerson(mail: Mail) {
        
        if let person = find(penpals.map({ $0.username }), mail.from) {
            self.from = penpals[person]
            self.fromLabel.text = penpals[person].name
        }
        else {
            self.fromLabel.text = mail.from
        }
        
    }
    
    func setStyleBasedOnMailStatus() {
        switch mail.status {
            case "DELIVERED":
                fromLabel.font = UIFont (name: "OpenSans-Semibold", size: 17)
            default:
                fromLabel.font = UIFont (name: "OpenSans-Light", size: 17)
        }
    }
    
    func getImage(mail: Mail) -> UIImage {
        if mail.image != nil {
            if let image = UIImage(named: mail.image) {
                return image
            }
        }
        return UIImage(named: "Default Card.png")!
    }
    
    func setStatusLabel() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if mail.status == "DELIVERED" {
            arrivalLabel.text = "Arrived on \(dateFormatter.stringFromDate(mail.scheduledToArrive))"
        }
        else if mail.status == "READ" {
            arrivalLabel.text = "Read on \(dateFormatter.stringFromDate(mail.updatedAt))"
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
