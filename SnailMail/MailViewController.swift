//
//  MailViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {
    

    
    @IBOutlet weak var mailText: UITextView!
    
    var mail:Mail!
    var from:Person!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailText.text = generateMailText()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateMailText () -> String {
        var mailText:String = "\(mail.content)"
        return mailText
    }
    
    @IBAction func closeMailView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

}