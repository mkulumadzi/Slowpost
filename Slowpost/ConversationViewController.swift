//
//  ConversationViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var person:Person!
    var conversation:[Mail]!
    @IBOutlet weak var mailTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateConversation()
        refreshConversation()
        mailTable.reloadData()
        
        mailTable.addSubview(self.refreshControl)
        
        // Calculating row height automatically; can't get it working with autolayout.
        mailTable.rowHeight = 75 + (view.frame.width - 20) * 0.75
        
        mailTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: mailTable.bounds.size.width, height: 0.01))
        
        navBarItem.title = person.name
        NSNotificationCenter.defaultCenter().addObserverForName("imageDownloaded:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.mailTable.reloadData()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("appBecameActive:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.refreshConversation()
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
        return conversation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as? ConversationMailCell
        let mail = conversation[indexPath.row] as Mail
        
        cell!.mail = mail
        cell!.person = person
        cell!.row = indexPath.row
        
        cell!.formatCell()
        
        if mail.imageUid != nil && mail.image == nil && mail.currentlyDownloadingImage == false {
            downloadMailImages(mail)
        }
        
        return cell!
        
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
    
    func populateConversation() {
        conversation = mailbox.filter({$0.from == self.person.username}) + outbox.filter({$0.to == self.person.username})
        conversation = conversation.sorted { $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedDescending }
    }
    
    
    func refreshConversation() {
        
        //Endpoint for conversation between logged in user and the selected person
        let conversationURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)/conversation/id/\(person.id)"
        
        var headers:[String: String]?
        if conversation.count > 0 {
            headers = RestService.sinceHeader(conversation)
        }
        
        MailService.getMailCollection(conversationURL, headers: headers, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                self.conversation = MailService.updateMailCollectionFromNewMail(self.conversation, newCollection: mailArray)
                self.conversation = self.conversation.sorted { $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending }
                
                MailService.appendMailArrayToCoreData(mailArray)
                
                self.mailTable.reloadData()
            }
        })
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshConversation()
        refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewMail" {
            let conversationMailViewController = segue.destinationViewController as? ConversationMailViewController
            if let mailCell = sender as? ConversationMailCell {
                conversationMailViewController?.mail = mailCell.mail
                conversationMailViewController?.person = mailCell.person
                conversationMailViewController?.row = mailCell.row
                conversationMailViewController?.personLabelValue = mailCell.personLabel.text
                conversationMailViewController?.statusLabelValue = mailCell.statusLabel.text
                
            }
        }
    }
    

}
