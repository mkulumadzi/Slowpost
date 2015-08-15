//
//  MailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {
    
    @IBOutlet weak var mailImage: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mailContent: UILabel!
    
    var mail:Mail!
    var from:Person!
    var updatedMail:Mail!
    var row:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Mail_Opened_From_Inbox")
        
        mailImage.image = mail.image
        
        if mail.content != nil {
           mailContent.text = mail.content 
        }
        
        fromLabel.text = "From: " + from.name
        setStatusLabel()
        
        if mail.status == "DELIVERED" {
            readMail(mail)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateMailText () -> String {
        var mailText:String = "\(mail.content)"
        return mailText
    }
    
    func readMail(mail:Mail) {
        let readMailURL = "\(PostOfficeURL)/mail/id/\(mail.id)/read"
        
        RestService.postRequest(readMailURL, parameters: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else {
                self.updateMail(mail)
            }
        })
    }
    
    func updateMail(mail:Mail) {
        
        MailService.getMailById(mail.id, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else {
                self.updatedMail = result as! Mail
                mailbox[self.row] = self.updatedMail
                
                //Ensure core data is also updated
                var tempMailArray = [Mail]()
                tempMailArray.append(self.updatedMail)
                MailService.appendMailArrayToCoreData(tempMailArray)
                
            }
        })
        
    }
    
    func setStatusLabel() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        statusLabel.text = "\(mail.status) on \(dateFormatter.stringFromDate(mail.updatedAt))"
    }
    
    @IBAction func closeMailView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

}