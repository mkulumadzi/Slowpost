//
//  WelcomePageItemViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/12/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class WelcomePageItemViewController: UIViewController {
    
    var itemIndex: Int = 0
    var labelValue = ""
    
    @IBOutlet weak var pageLabel = UILabel.new()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
