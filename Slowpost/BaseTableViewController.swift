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
        warningLabel = initializeWarningLabel()
    }

}
