//
//  ConversationTabViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationTabPlaceholderViewController: UIViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showConversations()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showConversations() {
        
        let storyboard = UIStoryboard(name: "conversations", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as UIViewController!
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
        
    }

}
