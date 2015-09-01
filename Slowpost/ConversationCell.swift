//
//  ConversationCell.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    var conversationMetadata:ConversationMetadata!
    var cellLabel:UIView!
    @IBOutlet weak var personNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cellLabel = addConversationCellLabel()
        self.addSubview(cellLabel)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addConversationCellLabel() -> UIView {
        cellLabel = UIView(frame: CGRect(x: 10.0, y: 13.5, width: 14, height: 14))
        cellLabel.layer.cornerRadius = 7
        cellLabel.backgroundColor = UIColor.clearColor()
        return cellLabel
    }

}
