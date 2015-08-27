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
        Flurry.logEvent("Opened_Profile_View")
        
        super.viewDidLoad()
        messageLabel.hide()
        noResultsLabel.hidden = true
        
        refreshPenpals()
        
        self.sentMailTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.sentMailTable.bounds.size.width, height: 0.01))
        
        navBarTitle.title = "@" + loggedInUser.username
        nameLabel.text = loggedInUser.name
        emailLabel.text = loggedInUser.email
        phoneLabel.text = loggedInUser.phone
        
        NSNotificationCenter.defaultCenter().addObserverForName("imageDownloaded:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.sentMailTable.reloadData()
        })
        
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
        
        if mail.imageUid != nil && mail.image == nil && mail.currentlyDownloadingImage == false {
            downloadMailImages(mail)
        }
        else if mail.imageUid == nil {
            mail.image = UIImage(named: "Default Card.png")!
            MailService.addImageToCoreDataMail(mail.id, image: mail.image, key: "image")
            mail.imageThumb = UIImage(named: "Default Card.png")!
            MailService.addImageToCoreDataMail(mail.id, image: mail.imageThumb, key: "image")
        }
        
        cell?.formatCell()
        
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
    
    @IBAction func showSettingsMenu(sender: AnyObject) {
        Flurry.logEvent("Opened_Settings_Menu")
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
        Flurry.logEvent("Cancelled_Back_To_Profile_View")
    }
    
    @IBAction func completeEditingAndReturnToProfileViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func choseToLogOut(segue:UIStoryboardSegue) {
        LoginService.logOut()
        self.dismissViewControllerAnimated(true, completion: {})
    }

}
