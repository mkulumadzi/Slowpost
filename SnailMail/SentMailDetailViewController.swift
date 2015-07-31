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
        
        getImage()
        mailContent.text = mail.content
        toLabel.text = "To: " + toPerson.name
        statusLabel.text = mail.status
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    @IBAction func closeView(sender: AnyObject) {
        
        //Connecting this button to the unwind segue on Profile View wasn't working, so dismissing view manually
        self.dismissViewControllerAnimated(true, completion: {})
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
