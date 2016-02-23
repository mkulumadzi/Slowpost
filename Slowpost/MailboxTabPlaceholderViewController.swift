//
//  MailboxTabPlaceholderViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailboxTabPlaceholderViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        showMailbox()
    }
    
    //MARK: Private
    
    private func showMailbox() {
        let storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()!
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }

}
