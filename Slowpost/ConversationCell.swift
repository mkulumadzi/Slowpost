//
//  ConversationCell.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    var conversation:Conversation!
    @IBOutlet weak var namesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    //MARK: Setup
    
    private func configure() {
        let cellLabel = addConversationCellLabel()
        addSubview(cellLabel)
    }
    
    private func addConversationCellLabel() -> CellLabelUIView {
        let cellLabel:CellLabelUIView = CellLabelUIView(frame: CGRect(x: 10, y: 16, width: 12, height: 12))
        cellLabel.layer.cornerRadius = 6
        cellLabel.backgroundColor = UIColor.clearColor()
        return cellLabel
    }

}
