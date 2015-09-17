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
    
    func addConversationCellLabel() -> CellLabelUIView {
        let cellLabel:CellLabelUIView = CellLabelUIView(frame: CGRect(x: 10, y: 16, width: 12, height: 12))
        cellLabel.layer.cornerRadius = 6
        cellLabel.backgroundColor = UIColor.clearColor()
        return cellLabel
    }

}
