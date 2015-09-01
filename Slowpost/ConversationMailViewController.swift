//
//  ConversationMailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationMailViewController: UIViewController {

    @IBOutlet weak var mailImage: UIImageView!
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mailContent: UILabel!
    
    var mail:Mail!
    var person:Person!
    var updatedMail:Mail!
    var row:Int!
    var personLabelValue:String!
    var statusLabelValue:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Mail_Opened_From_Conversation")
        
        mailImage.image = mail.image
        personLabel.text = personLabelValue
        statusLabel.text = statusLabelValue
        
        if mail.content != nil {
            mailContent.text = mail.content
        }
        
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
        
        RestService.postRequest(readMailURL, parameters: nil, headers: nil, completion: { (error, result) -> Void in
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
    
    @IBAction func closeMailView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
