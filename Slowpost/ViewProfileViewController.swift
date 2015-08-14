//
//  ViewProfileViewController.swift
//  Slowpost
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
    @IBOutlet weak var noResultsLabel: UILabel!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.hide()
        noResultsLabel.hidden = true
        
        refreshPenpals()
        
        self.sentMailTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.sentMailTable.bounds.size.width, height: 0.01))
        
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
    
    func refreshPenpals() {
        let contactsURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/contacts"
        PersonService.getPeopleCollection(contactsURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let peopleArray = result as? Array<Person> {
                penpals = peopleArray
                self.updateOutbox()
            }
        })
    }

    func updateOutbox() {
        let myOutboxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/outbox"
        
        var headers:[String: String]?
        if outbox.count > 0 {
            headers = RestService.sinceHeader(outbox)
        }
        
        MailService.getMailCollection(myOutboxURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                outbox = MailService.updateMailCollectionFromNewMail(outbox, newCollection: mailArray)
                outbox = outbox.sorted { $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedDescending }
                
                MailService.appendMailArrayToCoreData(mailArray)
                
                self.validateNoResultsLabel()
                self.sentMailTable.reloadData()
            }
        })
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshPenpals()
        refreshControl.endRefreshing()
    }
    
    func validateNoResultsLabel() {
        if outbox.count == 0 {
            noResultsLabel.hidden = false
        }
        else {
            noResultsLabel.hidden = true
        }
    }
    
    //MARK: Configure sections
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if outbox.count > 0 {
            return "Sent mail"
        }
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outbox.count
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
        header.textLabel.font = UIFont(name: "OpenSans-Semibold", size: 15)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34.0
    }
    
    
    //MARK: Configure rows
    
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
