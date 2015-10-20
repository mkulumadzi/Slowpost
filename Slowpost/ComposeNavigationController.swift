//
//  ComposeNavigationController.swift
//  Slowpost
//
//  Created by Evan Waters on 10/6/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit

class ComposeNavigationController: UINavigationController {
    
    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
