//
//  ComposeMailViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class ComposeMailViewController: UIViewController {
    
    var imageName:String!
    @IBOutlet weak var composeText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resignFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backToCard(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectRecipient" {
            let toViewController = segue.destinationViewController as? ToViewController
            if let contents = composeText.text {
                toViewController?.contents = contents
            }
            if let name = imageName {
                toViewController?.imageName = name
            }
        }
    }

}
