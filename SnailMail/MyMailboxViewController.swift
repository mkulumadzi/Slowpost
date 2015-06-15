//
//  MyMailboxViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MyMailboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var mailTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //To do: Figure out how to pause loading this view until the mailbox has finished loading

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
        let fromPerson = getPerson(mail.from)
        
        cell?.mail = mail
        cell?.from = fromPerson
        cell?.fromLabel.text = "From: \(fromPerson.name)"
        
        return cell!
        
    }
    
    //I'm sure there is a better way to do this...
    func getPerson(username: String) -> Person {
        var person_to_get:Person!
        for person in people {
            if person.username == username {
                person_to_get = person
            }
        }
        return person_to_get
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
