//
//  ComposeTabViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 7/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ComposeTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        compose()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func compose() {
        var storyboard = UIStoryboard(name: "compose", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
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
