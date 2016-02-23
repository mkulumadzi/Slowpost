//
//  ComposeTabPlaceholderViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ComposeTabPlaceholderViewController: BaseViewController, UITabBarDelegate {
    
    @IBOutlet weak var composeTabBarItem: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        composeMessage()
    }
    
    //MARK: Private
    
    private func composeMessage() {
        let storyboard = UIStoryboard(name: "to", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! BaseNavigationController
        presentViewController(controller, animated: true, completion: { () -> Void in
            self.tabBarController!.selectedIndex = 0
        })
    }

}
