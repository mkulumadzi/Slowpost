//
//  SearchPersonCell.swift
//  Slowpost
//
//  Created by Evan Waters on 10/5/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class SearchPersonCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    var searchPerson:SearchPerson!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
