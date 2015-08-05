//
//  SentMailDetailViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 7/27/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SentMailDetailViewController: UIViewController {

    var toPerson:Person!
    var mail:Mail!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var mailContent: UILabel!
    @IBOutlet weak var mailImage: UIImageView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailImage.image = mail.image
        
        if mail.content != nil {
            mailContent.text = mail.content
        }

        toLabel.text = "To: " + toPerson.name
        statusLabel.text = mail.status
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setStatusLabel() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        statusLabel.text = "\(mail.status) on \(dateFormatter.stringFromDate(mail.updatedAt))"
    }
    
    @IBAction func closeView(sender: AnyObject) {
        
        //Connecting this button to the unwind segue on Profile View wasn't working, so dismissing view manually
        self.dismissViewControllerAnimated(true, completion: {})
    }

    

}
