//
//  MyMailboxViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class MyMailboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mailTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailTable.reloadData()
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        mailTable.addSubview(self.refreshControl)
        
        // Calculating row height automatically; can't get it working with autolayout.
        mailTable.rowHeight = 75 + (view.frame.width - 20) * 0.75
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
    
    func refreshMailbox() {
        
        //Refresh mailbox by retrieving mail for the user
        let myMailBoxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/mailbox"
        
        let headers = RestService.sinceHeader(mailbox)
        
        MailService.getMailCollection(myMailBoxURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                mailbox = MailService.updateMailCollectionFromNewMail(mailbox, newCollection: mailArray)
                mailbox = mailbox.sorted { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
                
                MailService.appendMailArrayToCoreData(mailArray)
                
                self.mailTable.reloadData()
            }
        })
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshMailbox()
        refreshControl.endRefreshing()
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


}
