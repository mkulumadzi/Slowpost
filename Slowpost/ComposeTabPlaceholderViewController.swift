//
//  ComposeTabPlaceholderViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ComposeTabPlaceholderViewController: UIViewController, UITabBarDelegate {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBOutlet weak var composeTabBarItem: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        composeMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func composeMessage() {
        var storyboard = UIStoryboard(name: "compose", bundle: nil)
        var controller = storyboard.instantiateInitialViewController() as! ComposeNavigationController
        self.presentViewController(controller, animated: true, completion: { () -> Void in
            self.tabBarController!.selectedIndex = 0
        })
    }

}
