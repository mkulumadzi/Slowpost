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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshPenpals()
        mailTable.reloadData()
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        mailTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.mailTable.bounds.size.width, height: 0.01))
        mailTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        mailTable.addSubview(self.refreshControl)
        
        // Calculating row height automatically; can't get it working with autolayout.
        mailTable.rowHeight = 85 + (view.frame.width - 20) * 0.75

        NSNotificationCenter.defaultCenter().addObserverForName("imageDownloaded:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.mailTable.reloadData()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("appBecameActive:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.refreshMailbox()
        })
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as! MailCell
        let mail = mailbox[indexPath.row] as Mail
        
        cell.mail = mail
        
        let person = PersonService.getPersonFromUsername(mail.from)
        
        if person != nil {
            cell.from = person!
            cell.fromViewInitials.text = person!.initials()
            cell.fromLabel.text = cell.from.name
        }
        
        cell.mailImage.image = mail.image
        
        let deliveredDateString = mail.createdAt.formattedAsString("yyyy-MM-dd")
        cell.deliveredLabel.text = "Delivered on \(deliveredDateString)"
        
        formatMailCellBasedOnMailStatus(cell, mail: mail)
        
        if mail.imageUid != nil && mail.image == nil && mail.currentlyDownloadingImage == false {
            downloadMailImages(mail)
        }
        
        return cell
        
    }
    
    func formatMailCellBasedOnMailStatus(cell: MailCell, mail: Mail) {
        if mail.status == "DELIVERED" {
            cell.fromLabel.font = UIFont(name: "OpenSans-Semibold", size: 17.0)
            cell.statusIndicator.backgroundColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
            cell.statusIndicator.layer.borderWidth = 0.0
        }
        else {
            cell.fromLabel.font = UIFont(name: "OpenSans-Regular", size: 17.0)
            cell.statusIndicator.backgroundColor = UIColor.whiteColor()
            cell.statusIndicator.layer.borderColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0).CGColor
            cell.statusIndicator.layer.borderWidth = 1.0
            
        }
    }
    
    func downloadMailImages(mail: Mail) {
        mail.currentlyDownloadingImage = true
        downloadMailThumbnail(mail)
    }
    
    func downloadMailThumbnail(mail: Mail) {
        
        MailService.getMailThumbnailImage(mail, completion: { (error, result) -> Void in
            if let thumbnail = result as? UIImage {
                mail.imageThumb = thumbnail
                MailService.addImageToCoreDataMail(mail.id, image: thumbnail, key: "imageThumb")
                self.downloadMailImage(mail)
            }
        })
    }
    
    func downloadMailImage(mail: Mail) {
        MailService.getMailImage(mail, completion: { (error, result) -> Void in
            if let image = result as? UIImage {
                mail.image = image
                MailService.addImageToCoreDataMail(mail.id, image: image, key: "image")
                mail.currentlyDownloadingImage = false
            }
        })
    }
    
    func refreshPenpals() {
        let contactsURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/contacts"
        PersonService.getPeopleCollection(contactsURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let peopleArray = result as? Array<Person> {
                penpals = peopleArray
                self.refreshMailbox()
            }
        })
    }
    
    func refreshMailbox() {
        
        //Refresh mailbox by retrieving mail for the user
        let myMailBoxURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/mailbox"
        
        var headers:[String: String]?
        if mailbox.count > 0 {
            headers = RestService.sinceHeader(mailbox)
        }
        
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
        refreshPenpals()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mail = mailbox[indexPath.row]
        var storyboard = UIStoryboard(name: "mail", bundle: nil)
        var mailViewController = storyboard.instantiateInitialViewController() as! MailViewController
        mailViewController.mail = mail
        mailViewController.runOnClose = {self.refreshMailbox()}
        
        self.presentViewController(mailViewController, animated: true, completion: {})
    }


}
