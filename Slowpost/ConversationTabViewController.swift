//
//  ConversationTabViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationTabPlaceholderViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        showConversations()
    }

    //MARK: Private
    private func showConversations() {
        let storyboard = UIStoryboard(name: "conversations", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as UIViewController!
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }

}
