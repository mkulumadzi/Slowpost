//
//  MailViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {
    
//    @IBOutlet weak var mailText: UITextView!
//    @IBOutlet weak var mailImage: UIImageView!
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
        
        getImage()
        mailContent.text = mail.content
        fromLabel.text = "From: " + from.name
        setStatusLabel()
        
        if mail.status == "DELIVERED" {
            readMail(mail)
        }

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
    
    func getImage() {
        if mail.image != nil {
            mailImage.image = mail.image
        }
        else {
            MailService.getMailImage(mail, completion: { (error, result) -> Void in
                if let image = result as? UIImage {
                    self.mailImage.image = image
                }
                else {
                    self.mailImage.image = UIImage(named: "Default Card.png")!
                }
            })
        }
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
        
        MailService.getMailById(mail.id, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else {
                self.updatedMail = result as! Mail
                mailbox[self.row] = self.updatedMail
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