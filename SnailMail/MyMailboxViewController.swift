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
        mailTable.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        mailTable.reloadData()
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
        
        cell!.mail = mail
        cell!.row = indexPath.row
        
        cell!.formatCell()
        
        return cell!
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewMail" {
            let mailViewController = segue.destinationViewController as? MailViewController
            if let mailCell = sender as? MailCell {
                mailViewController?.mail = mailCell.mail
                mailViewController?.from = mailCell.from
                mailViewController?.row = mailCell.row
                
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
