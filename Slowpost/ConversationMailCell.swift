//
//  ConversationMailCell.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationMailCell: UITableViewCell {

//    @IBOutlet weak var personLabel: UILabel!
//    @IBOutlet weak var statusLabel: UILabel!
//    @IBOutlet weak var mailImage: UIImageView!
    
    var mail:Mail!
    var person:Person!
    var row:Int!
    var containerView:CustomContainerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in self.contentView.subviews {
            view.removeFromParentViewController()
        }
        
        containerView = CustomContainerView(frame: CGRect(x: 10, y: 10, width: self.frame.width - 20, height: self.frame.height-20))
        containerView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(containerView)
        
    }
    
    func addMailViewToContainer(mail: Mail) {
        containerView.addSubview(getViewForMail(mail))
    }
    
    func getViewForMail(mail: Mail) -> UIView {
        let customView = UIView()
        customView.backgroundColor = UIColor.clearColor()
        
        // Layout out sizes
        let cardWidth = self.frame.width * 2 / 3
        let imageHeight = self.frame.width / 2
        let labelHeight:CGFloat = 20
        let cardHeight = imageHeight + labelHeight
        
        let mailCardView = UIView(frame: CGRect(x: cardXPosition(mail), y: 0, width: cardWidth, height: cardHeight))
        mailCardView.backgroundColor = UIColor.whiteColor()
        
        let mailImage = UIImageView()
        mailImage.image = mail.image
        mailImage.frame = CGRect(x: 0, y: 0, width: cardWidth, height: imageHeight)
        
        let statusLabel = UILabel()
        statusLabel.text = "\(mail.status) on \(formatUpdatedDate(mail.updatedAt))"
        statusLabel.frame = CGRect(x: 0, y: imageHeight, width: cardWidth, height: 20)
        statusLabel.font = UIFont(name: "OpenSans-Light", size: 13.0)
        statusLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
        
        mailCardView.addSubview(mailImage)
        mailCardView.addSubview(statusLabel)
        
        customView.addSubview(mailCardView)
        
        return customView
        
    }
    
    func cardXPosition(mail: Mail) -> CGFloat {
        if mail.to == loggedInUser.username {
            return 35.0
        }
        else {
            return self.frame.width / 3 - 35
        }
    }
    
    func formatUpdatedDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(date)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
