//
//  CardCollectionViewCell.swift
//  SnailMail
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var checkMarkIcon: UIImageView!
    
    override var selected : Bool {
        didSet {
            if selected {
                self.checkMarkIcon.image = UIImage(named: "ios7-checkmark.png")
            }
            else {
                self.checkMarkIcon.image = UIImage(named: "ios7-checkmark-not-checked.png")
            }
        }
    }
    
}
