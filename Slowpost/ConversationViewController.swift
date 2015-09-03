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
    var undeliveredMail:[Mail]!
    var deliveredMail:[Mail]!
    
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
//        mailTable.reloadData()
        
        mailTable.addSubview(self.refreshControl)
        
//         Calculating row height automatically; can't get it working with autolayout.
        mailTable.rowHeight = 45 + view.frame.width / 2
        
        mailTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: mailTable.bounds.size.width, height: 0.01))
        mailTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        navBarItem.title = person.name
        NSNotificationCenter.defaultCenter().addObserverForName("imageDownloaded:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.mailTable.reloadData()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("appBecameActive:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.refreshConversation()
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        println("View appeared")
        super.viewDidAppear(true)
        refreshConversation()
//        mailTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if undeliveredMail.count > 0 {
                return "Undelivered mail"
            }
        case 1:
            if deliveredMail.count > 0 {
                return "Delivered mail"
            }
        default:
            return nil
        }
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return undeliveredMail.count
        case 1:
            return deliveredMail.count
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
        header.textLabel.font = UIFont(name: "OpenSans-Semibold", size: 13)
        header.textLabel.textAlignment = NSTextAlignment.Center
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if undeliveredMail.count == 0 {
                return 0.0
            }
        case 1:
            if deliveredMail.count == 0 {
                return 0.0
            }
        default:
            return 34.0
        }
        return 34.0
    }
    
    // MARK: Row configuration
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let mail = conversation[indexPath.row] as Mail
        let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as? ConversationMailCell
        
        switch indexPath.section {
        case 0:
            cell!.mail = undeliveredMail[indexPath.row]
            cell!.row = indexPath.row
            formatCell(cell!)
        case 1:
            cell!.mail = deliveredMail[indexPath.row]
            cell!.row = indexPath.row
            formatCell(cell!)
        default:
            cell!.row = 0
        }
        return cell!
    }
    
    func formatCell(cell: ConversationMailCell) {
        cell.person = person
        let updatedDateString = cell.mail.updatedAt.formattedAsString("yyyy-MM-dd")
        cell.statusLabel.text = "\(cell.mail.status) on \(updatedDateString)"
        
        cell.mailImageView.image = cell.mail.image
        
        formatMailStatusLabel(cell)
        
        if cell.mail.to == person.username {
            cell.leadingSpaceToFromView.priority = 251
            cell.trailingSpaceFromFromView.priority = 999
            
            cell.leadingSpaceToCardView.priority = 251
            cell.trailingSpaceFromCardView.priority = 999
            
            cell.initialsLabel.text = loggedInUser.initials()
        }
        else {
            cell.leadingSpaceToFromView.priority = 999
            cell.trailingSpaceFromFromView.priority = 251
            
            cell.leadingSpaceToCardView.priority = 999
            cell.trailingSpaceFromCardView.priority = 251
            
            cell.initialsLabel.text = person.initials()
        }
        
        if cell.mail.imageUid != nil && cell.mail.image == nil && cell.mail.currentlyDownloadingImage == false {
            downloadMailImages(cell.mail)
        }
    }
    
    func formatMailStatusLabel(cell: ConversationMailCell) {
        if cell.mail.to == loggedInUser.username {
            if cell.mail.status == "DELIVERED" {
                cell.mailStatusLabel.backgroundColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
                cell.statusLabel.textColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1.0)
                cell.mailStatusLabel.layer.borderWidth = 0.0
            }
            else {
                cell.mailStatusLabel.backgroundColor = UIColor.whiteColor()
                cell.mailStatusLabel.layer.borderColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0).CGColor
                cell.statusLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
                cell.mailStatusLabel.layer.borderWidth = 1.0
            }
        }
        else {
            if cell.mail.status == "SENT" {
                cell.mailStatusLabel.backgroundColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
                cell.mailStatusLabel.layer.borderWidth = 0.0
            }
            else {
                cell.mailStatusLabel.backgroundColor = UIColor.whiteColor()
                cell.mailStatusLabel.layer.borderColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0).CGColor
                cell.mailStatusLabel.layer.borderWidth = 1.0
            }
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
    
    func populateConversation() {
        conversation = mailbox.filter({$0.from == self.person.username}) + outbox.filter({$0.to == self.person.username})
        conversation = conversation.sorted { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
        populateSections()

    }
    
    func populateSections() {
        undeliveredMail = conversation.filter({$0.status == "SENT"})
        deliveredMail = conversation.filter({$0.status != "SENT"})
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
                self.conversation = self.conversation.sorted { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
                self.populateSections()
                
                MailService.appendMailArrayToCoreData(mailArray)
                
                self.mailTable.reloadData()
            }
        })
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshConversation()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var mail:Mail!
        switch indexPath.section {
        case 0:
            mail = undeliveredMail[indexPath.row]
        case 1:
            mail = deliveredMail[indexPath.row]
        default:
            println("No mail at seleted row")
        }
        
        if mail != nil {
            var storyboard = UIStoryboard(name: "mail", bundle: nil)
            var mailViewController = storyboard.instantiateInitialViewController() as! MailViewController
            mailViewController.mail = mail
            mailViewController.runOnClose = {self.refreshConversation()}
            self.presentViewController(mailViewController, animated: true, completion: {})
        }
    }
    

}
