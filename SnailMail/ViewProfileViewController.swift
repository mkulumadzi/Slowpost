//
//  ViewProfileViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/15/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ViewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sentMailTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var messageLabel: MessageUILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.hide()
        
        updateOutbox()
        
        navBarTitle.title = "@" + loggedInUser.username
        nameLabel.text = loggedInUser.name
        emailLabel.text = loggedInUser.email
        phoneLabel.text = loggedInUser.phone
        
        sentMailTable.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        sentMailTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateOutbox() {
        let myOutboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/outbox"
        
        let headers = RestService.sinceHeader(outbox)
        
        MailService.getMailCollection(myOutboxURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                outbox = MailService.updateMailCollectionFromNewMail(outbox, newCollection: mailArray)
                
                outbox = outbox.sorted { $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending }
                self.sentMailTable.reloadData()
            }
        })
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        updateOutbox()
        refreshControl.endRefreshing()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sent mail"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outbox.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as? SentMailTableViewCell
        
        let mail = outbox[indexPath.row] as Mail
        cell?.mail = mail
        
        if let person = find(penpals.map({ $0.username }), mail.to) {
            cell?.person = penpals[person]
        }
        
        cell?.formatCell()
        
        return cell!
    }
    
    @IBAction func showSettingsMenu(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettingsMenu", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewSentMail" {
            let sentMailDetailViewController = segue.destinationViewController as? SentMailDetailViewController
            if let mailCell = sender as? SentMailTableViewCell {
                sentMailDetailViewController!.mail = mailCell.mail
                sentMailDetailViewController!.toPerson = mailCell.person
            }
        }
    }
    
    @IBAction func cancelToProfileViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func completeEditingAndReturnToProfileViewController(segue:UIStoryboardSegue) {
    }

}
