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
import CoreData
import Foundation

class MailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mailImage: UIImageView!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var fromViewInitials: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var deliveredLabel: UILabel!
    @IBOutlet weak var mailContent: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var managedContext:NSManagedObjectContext!
    var mail:Mail!
    var fromPerson:Person!

    var runOnClose: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        
        Flurry.logEvent("Mail_Opened")
        
        addImage()
        fromView.layer.cornerRadius = 15

        fromPerson = mail.fromPerson
        fromLabel.text = fromPerson.fullName()
        fromViewInitials.text = fromPerson.initials()
        toLabel.text = mail.toList()
        
        let sentDateString = mail.dateSent.formattedAsString("yyyy-MM-dd")
        sentLabel.text = "Sent on \(sentDateString)"
        
        if mail.status != "SENT" {
            let deliveredDateString = mail.dateDelivered.formattedAsString("yyyy-MM-dd")
            deliveredLabel.text = "Delivered on \(deliveredDateString)"
        }
        else {
            deliveredLabel.text = ""
        }
        
        mailContent.text = mail.content()
        
        if mail.myStatus != "READ" && mail.toLoggedInUser() {
            readMail(mail)
        }
        
        let userId = LoginService.getUserIdFromToken()
        if fromPerson.id == userId {
            navItem.rightBarButtonItem = nil
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addImage() {
        mail.getImage({error, result -> Void in
            if let image = result as? UIImage {
                self.mailImage.image = image
            }
        })
    }
    
    func readMail(mail:Mail) {
        let readMailURL = "\(PostOfficeURL)/mail/id/\(mail.id)/read"
        RestService.postRequest(readMailURL, parameters: nil, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
        })
    }
    
    @IBAction func replyToMail(sender: AnyObject) {
        var toPeople = [Person]()
        let userId = LoginService.getUserIdFromToken()
        for item in mail.conversation.people.allObjects {
            let person = item as! Person
            if person.id != userId {
                toPeople.append(person)
            }
        }
        var toEmails = [String]()
        for item in mail.conversation.emails.allObjects {
            let emailAddress = item as! EmailAddress
            toEmails.append(emailAddress.email)
        }

        let storyboard = UIStoryboard(name: "compose", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ComposeNavigationController!
        controller.toPeople = toPeople
        controller.toSearchPeople = [SearchPerson]()
        controller.toEmails = toEmails
        self.presentViewController(controller, animated: true, completion: {})
        
    }
    
    @IBAction func closeMailView(sender: AnyObject) {
        if runOnClose != nil { runOnClose!() }
        self.dismissViewControllerAnimated(true, completion: {})
    }
}

