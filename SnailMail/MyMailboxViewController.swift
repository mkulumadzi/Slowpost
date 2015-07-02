//
//  MyMailboxViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MyMailboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mailTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailbox.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as? MailCell
        
        let mail = mailbox[indexPath.row] as Mail
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        cell?.mail = mail
        
        getPersonForCell(cell!, mail: mail)
        
        cell?.arrivalLabel.text = "Arrived on \(dateFormatter.stringFromDate(mail.scheduledToArrive))"
        
        cell?.mailImage.image = getImage(mail)
        
        return cell!
        
    }
    
    func getPersonForCell(cell: MailCell, mail: Mail) {
        
        if let person = find(people.map({ $0.username }), mail.from) {
            cell.from = people[person]
            cell.fromLabel.text = people[person].name
        }
        else {
            cell.fromLabel.text = mail.from
        }
    }
    
    func getImage(mail: Mail) -> UIImage {
        if mail.image != nil {
            if let image = UIImage(named: mail.image) {
                return image
            }
        }
        return UIImage(named: "Default Card.png")!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewMail" {
            let mailViewController = segue.destinationViewController as? MailViewController
            if let mailCell = sender as? MailCell {
                mailViewController?.mail = mailCell.mail
                mailViewController?.from = mailCell.from
                
            }
        }
    }
    
    
    @IBAction func Compose(sender: AnyObject) {
        
        var storyboard = UIStoryboard(name: "compose", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
    @IBAction func Profile(sender: AnyObject) {
        
        var storyboard = UIStoryboard(name: "profile", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: false, completion: nil)
        
    }

}
