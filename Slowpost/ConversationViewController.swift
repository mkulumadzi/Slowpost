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
        
//         Calculating row height automatically; can't get it working with autolayout.
        mailTable.rowHeight = 40 + view.frame.width / 2
        
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
        let mail = conversation[indexPath.row] as Mail
        let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as? ConversationMailCell
        cell!.mail = mail
        cell!.person = person
        cell!.row = indexPath.row
        
        cell!.addMailViewToContainer(mail)
        
//        addSubviewToCellContainerView(cell!)
        
//        if mail.from == person.username {
//            cell!.addSubview(getViewForMailFromPerson(mail))
//        }
//        if mail.to == person.username {
//            cell!.addSubview(getViewForMailToPerson(mail))
//        }
//        
        if mail.imageUid != nil && mail.image == nil && mail.currentlyDownloadingImage == false {
            downloadMailImages(mail)
        }
        
        return cell!
        
    }
    
//    func addSubviewToCellContainerView(cell: ConversationMailCell) {
//        
//        for view in cell.subviews {
//            if var containerView = view as? CustomContainerView {
//                if cell.mail.to == loggedInUser.username {
//                    containerView = getViewForMailFromPerson(cell.mail)
//                }
//                else if cell.mail.from == loggedInUser.username {
//                    containerView = getViewForMailToPerson(cell.mail)
//                }
//            }
//        }
//    }
    
//    func getViewForMailToPerson(mail: Mail) -> UIView {
//        let customView = UIView(frame: CGRect(x: 10, y: 10, width: self.view.frame.width - 10, height: self.view.frame.height - 10))
////        let customView = CustomContainerView(frame: CGRect(x: 10, y: 10, width: self.view.frame.width - 10, height: self.view.frame.height - 10))
//        customView.backgroundColor = UIColor.clearColor()
//        
//        // Layout out sizes
//        let cardWidth = self.view.frame.width * 2 / 3
//        let imageHeight = self.view.frame.width / 2
//        let labelHeight:CGFloat = 20
//        let cardHeight = imageHeight + labelHeight
//        
//        let mailCardView = UIView(frame: CGRect(x: self.view.frame.width - cardWidth - 35, y: 0, width: cardWidth, height: cardHeight))
//        mailCardView.backgroundColor = UIColor.whiteColor()
//        
//        let mailImage = UIImageView()
//        mailImage.image = mail.image
//        mailImage.frame = CGRect(x: 0, y: 0, width: cardWidth, height: imageHeight)
//        
//        let statusLabel = UILabel()
//        statusLabel.text = "\(mail.status) on \(formatUpdatedDate(mail.updatedAt))"
//        statusLabel.frame = CGRect(x: 0, y: imageHeight, width: cardWidth, height: 20)
//        statusLabel.font = UIFont(name: "OpenSans-Light", size: 13.0)
//        statusLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
//        
//        mailCardView.addSubview(mailImage)
//        mailCardView.addSubview(statusLabel)
//        
//        customView.addSubview(mailCardView)
//        
//        return customView
//        
//    }
    
//    func formatUpdatedDate(date: NSDate) -> String {
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.stringFromDate(date)
//    }
    
//    func getViewForMailFromPerson(mail: Mail) -> CustomContainerView {
//        let customView = CustomContainerView()
//        var backgroundView = UIView(frame: CGRect(x: 5, y:5, width: self.frame.width - 60, height: self.frame.height - 10))
//        backgroundView.backgroundColor = UIColor.whiteColor()
//        self.addSubview(backgroundView)
//    }
//    
//    func formatMailFromPerson() {
//        var backgroundView = UIView(frame: CGRect(x: 5, y:5, width: self.frame.width - 60, height: self.frame.height - 10))
//        backgroundView.backgroundColor = UIColor.whiteColor()
//        self.addSubview(backgroundView)
//    }
//    
    
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
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "viewMail" {
//            let conversationMailViewController = segue.destinationViewController as? ConversationMailViewController
//            if let mailCell = sender as? ConversationMailCell {
//                conversationMailViewController?.mail = mailCell.mail
//                conversationMailViewController?.person = mailCell.person
//                conversationMailViewController?.row = mailCell.row
//                conversationMailViewController?.personLabelValue = mailCell.personLabel.text
//                conversationMailViewController?.statusLabelValue = mailCell.statusLabel.text
//                
//            }
//        }
//    }
    

}
