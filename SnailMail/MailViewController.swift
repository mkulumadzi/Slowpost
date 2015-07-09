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
    @IBOutlet weak var mailImage: UIImageView!
    
    var mail:Mail!
    var from:Person!
    var updatedMail:Mail!
    var row:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailText.text = generateMailText()
        mailImage.image = getImage()
        
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
    
    //To Do: Abstract this function into a separate class.
    func getImage() -> UIImage {
        if mail.image != nil {
            if let image = UIImage(named: mail.image) {
                return image
            }
        }
        return UIImage(named: "Default Card.png")!
    }
    
    func readMail(mail:Mail) {
        
        DataManager.readMail(mail, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else {
                self.updateMail(mail)
            }
        })
    }
    
    func updateMail(mail:Mail) {
        
        DataManager.getMailById(mail.id, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else {
                self.updatedMail = result as! Mail
                mailbox[self.row] = self.updatedMail
            }
        })
        
    }
    
    @IBAction func closeMailView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

}