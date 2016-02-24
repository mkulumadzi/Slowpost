//
//  ViewControllerExtensions.swift
//  Slowpost
//
//  Created by Evan Waters on 2/23/16.
//  Copyright © 2016 Evan Waters. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func addEdgeConstraintsToItem(item: UIView) {
        let leading = NSLayoutConstraint(item: item, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: item, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: item, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 60.0)
        let height = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30.0)
        item.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([leading, trailing, top, height])
    }
    
    func showLabelWithMessage(label: UILabel, message: String) {
        label.text = message
        UIView.animateWithDuration(0.5, animations: {
            label.alpha = 1.0
        })
    }
    
    func hideItem(item: UIView) {
        UIView.animateWithDuration(0.5, animations: {
            item.alpha = 0.0
        })
    }
    
}