//
//  MailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 9/3/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

//
//  ConversationMailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {
    
    @IBOutlet weak var mailImage: UIImageView!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var fromViewInitials: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var deliveredLabel: UILabel!
    @IBOutlet weak var mailContent: UILabel!
    
    var mail:Mail!
    var fromPerson:Person!
    var toPerson:Person!

    var runOnClose: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Mail_Opened")
        
        fromPerson = PersonService.getPersonFromUsername(mail.from)
        toPerson = PersonService.getPersonFromUsername(mail.to)
        
        mailImage.image = mail.image
        fromView.layer.cornerRadius = 15
        fromViewInitials.text = fromPerson.initials()
        
        fromLabel.text = fromPerson.name
        toLabel.text = toPerson.name
        
        let sentDateString = mail.createdAt.formattedAsString("yyyy-MM-dd")
        sentLabel.text = "Sent on \(sentDateString)"
        
        if mail.status != "SENT" {
            let deliveredDateString = mail.scheduledToArrive.formattedAsString("yyyy-MM-dd")
            deliveredLabel.text = "Delivered on \(deliveredDateString)"
        }
        else {
            deliveredLabel.text = ""
        }
        
        if mail.content != nil {
            mailContent.text = mail.content
        }
        
        if mail.status == "DELIVERED" && mail.to == loggedInUser.username {
            readMail(mail)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readMail(mail:Mail) {
        let readMailURL = "\(PostOfficeURL)/mail/id/\(mail.id)/read"
        RestService.postRequest(readMailURL, parameters: nil, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
        })
    }
    
    @IBAction func closeMailView(sender: AnyObject) {
        if runOnClose != nil { runOnClose!() }
        self.dismissViewControllerAnimated(true, completion: {})
    }
}

