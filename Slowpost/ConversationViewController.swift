//
//  ConversationViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var conversation:Conversation!

    var managedContext:NSManagedObjectContext!
    var undeliveredMailController:NSFetchedResultsController!
    var deliveredMailController:NSFetchedResultsController!
    
    @IBOutlet weak var mailTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var composeButton: UIButton!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedContext = CoreDataService.initializeManagedContext()
        
        MailService.updateConversationMail(conversation.id, managedContext: managedContext)
//        mailTable.reloadData()
        
        mailTable.addSubview(self.refreshControl)
        
//         Calculating row height automatically; can't get it working with autolayout.
        mailTable.rowHeight = 45 + view.frame.width / 2
        
        mailTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: mailTable.bounds.size.width, height: 0.01))
        mailTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        navBarItem.title = conversation.peopleNames()
        NSNotificationCenter.defaultCenter().addObserverForName("imageDownloaded:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.mailTable.reloadData()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("appBecameActive:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            MailService.updateConversationMail(self.conversation.id, managedContext: self.managedContext)
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("View appeared")
        super.viewDidAppear(true)
        MailService.updateConversationMail(conversation.id, managedContext: managedContext)
//        mailTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Mark: Set up Core Data
    func initializeUndeliveredMailController() {
        let fetchRequest = NSFetchRequest(entityName: "Mail")
        let dateSentSort = NSSortDescriptor(key: "dateSent", ascending: false)
        let predicate = NSPredicate(format: "status == %@ AND conversation == %@", ["SENT", conversation])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [dateSentSort]
        self.undeliveredMailController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        self.undeliveredMailController.delegate = self
        do {
            try self.undeliveredMailController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func initializeDeliveredMailController() {
        let fetchRequest = NSFetchRequest(entityName: "Mail")
        let dateDeliveredSort = NSSortDescriptor(key: "dateDelivered", ascending: false)
        let predicate = NSPredicate(format: "status == %@ AND conversation == %@", ["DELIVERED", conversation])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [dateDeliveredSort]
        self.undeliveredMailController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        self.undeliveredMailController.delegate = self
        do {
            try self.undeliveredMailController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if undeliveredMailController.sections!.count > 0 {
                return "Undelivered mail"
            }
        case 1:
            if deliveredMailController.sections!.count > 0 {
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
            return undeliveredMailController.sections!.count
        case 1:
            return deliveredMailController.sections!.count
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "OpenSans-Semibold", size: 13)
        header.textLabel!.textAlignment = NSTextAlignment.Center
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if undeliveredMailController.sections!.count == 0 {
                return 0.0
            }
        case 1:
            if deliveredMailController.sections!.count == 0 {
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
            cell!.mail = undeliveredMailController.objectAtIndexPath(indexPath) as! Mail
            cell!.row = indexPath.row
            formatCell(cell!)
        case 1:
            cell!.mail = deliveredMailController.objectAtIndexPath(indexPath) as! Mail
            cell!.row = indexPath.row
            formatCell(cell!)
        default:
            cell!.row = 0
        }
        return cell!
    }
    
    func formatCell(cell: ConversationMailCell) {
        
        generateStatusLabel(cell, mail: cell.mail)
        
        cell.mailImageView.image = cell.mail.image(managedContext)
        cell.initialsLabel.text = cell.mail.fromPerson.initials()
        
        formatMailStatusLabel(cell)
        
        if cell.mail.toLoggedInUser() == false {
            cell.leadingSpaceToFromView.priority = 251
            cell.trailingSpaceFromFromView.priority = 999
            cell.leadingSpaceToCardView.priority = 251
            cell.trailingSpaceFromCardView.priority = 999
        }
        else {
            cell.leadingSpaceToFromView.priority = 999
            cell.trailingSpaceFromFromView.priority = 251
            cell.leadingSpaceToCardView.priority = 999
            cell.trailingSpaceFromCardView.priority = 251
        }
        
    }
    
    func generateStatusLabel(cell: ConversationMailCell, mail: Mail) {
        if mail.status == "SENT" {
            let dateValue = mail.createdAt.formattedAsString("yyyy-MM-dd")
            cell.statusLabel.text = "Sent on \(dateValue)"
        }
        else {
            let dateValue = mail.scheduledToArrive.formattedAsString("yyyy-MM-dd")
            cell.statusLabel.text = "Delivered on \(dateValue)"
        }
    }
    
    func formatMailStatusLabel(cell: ConversationMailCell) {
        if cell.mail.toLoggedInUser() == true {
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
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        MailService.updateConversationMail(conversation.id, managedContext: managedContext)
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var mail:Mail!
        switch indexPath.section {
        case 0:
            mail = undeliveredMailController.objectAtIndexPath(indexPath) as! Mail
        case 1:
            mail = deliveredMailController.objectAtIndexPath(indexPath) as! Mail
        default:
            print("No mail at seleted row")
        }
        
        if mail != nil {
            let storyboard = UIStoryboard(name: "mail", bundle: nil)
            let mailViewController = storyboard.instantiateInitialViewController() as! MailViewController
            mailViewController.mail = mail
            mailViewController.runOnClose = {MailService.updateConversationMail(self.conversation.id, managedContext: self.managedContext)}
            self.presentViewController(mailViewController, animated: true, completion: {})
        }
    }
    
    
//    @IBAction func composeMessage(sender: AnyObject) {
//        let storyboard = UIStoryboard(name: "compose", bundle: nil)
//        let controller = storyboard.instantiateInitialViewController() as! ComposeNavigationController
//        controller.toUsername = person.username
//        self.presentViewController(controller, animated: true, completion: {})
//    }
    

}
