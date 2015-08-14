//
//  CustomUITableView.swift
//  Slowpost
//
//  Created by Evan Waters on 8/14/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class CustomUITableView: UITableView {
        
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.lightGrayColor()
        header.textLabel.textColor = UIColor.blackColor()
        header.textLabel.font = UIFont(name: "OpenSans-Semibold", size: 15)
    }

}
