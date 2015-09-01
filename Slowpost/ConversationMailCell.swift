//
//  ConversationMailCell.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationMailCell: UITableViewCell {

    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mailImage: UIImageView!
    
    var mail:Mail!
    var person:Person!
    var row:Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func formatCell() {
        getPerson(mail)
        setStyleBasedOnMailStatus()
        mailImage.image = mail.image
        setStatusLabel()
    }
    
    func getPerson(mail: Mail) {
        
        if let person = find(penpals.map({ $0.username }), mail.from) {
            self.person = penpals[person]
            self.personLabel.text = "From: \(self.person.name)"
        }
        else if let person = find(penpals.map({ $0.username }), mail.to) {
            self.person = penpals[person]
            self.personLabel.text = "To: \(self.person.name)"
        }
        else {
            self.personLabel.text = ""
            println("Couldn't find person in penpals")
        }
        
    }
    
    func setStyleBasedOnMailStatus() {
        switch mail.status {
        case "DELIVERED":
            personLabel.textColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1.0)
        default:
            personLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
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
