//
//  MailboxTabPlaceholderViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailboxTabPlaceholderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showMailbox()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMailbox() {
        
        var storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        var controller = storyboard.instantiateInitialViewController() as! UIViewController
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
