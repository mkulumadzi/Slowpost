//
//  BaseTableViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 2/23/16.
//  Copyright © 2016 Evan Waters. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //// TO DO: Stop duplicating this functionality from BaseViewController
    
    var warningLabel:UILabel!
    
    //MARK: UI Accessories
    
    func addWarningLabel() {
        warningLabel = UILabel()
        view.addSubview(warningLabel)
        warningLabel.backgroundColor = slowpostBlack
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.font = UIFont(name: "OpenSans", size: 15.0)
        warningLabel.textAlignment = .Center
        addEdgeConstraintsToItem(warningLabel)
        warningLabel.alpha = 0.0
    }
    
    func showWarningLabel(message: String) {
        warningLabel.text = message
        UIView.animateWithDuration(0.5, animations: {
            self.warningLabel.alpha = 1.0
        })
    }
    
    func hideWarningLabel() {
        UIView.animateWithDuration(0.5, animations: {
            self.warningLabel.alpha = 0.0
        })
    }
    
    //MARK: Autolayout helpers
    
    func addEdgeConstraintsToItem(item: UIView) {
        let leading = NSLayoutConstraint(item: item, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: item, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: item, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 60.0)
        let height = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30.0)
        item.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([leading, trailing, top, height])
    }

}
