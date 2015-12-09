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

    var fetchedResultsController: NSFetchedResultsController!
    
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
        Flurry.logEvent("Conversation_view_opened")
        
        initializeFetchedResultsController()
        formatButtons()
        
        refreshData()
        
        mailTable.addSubview(refreshControl)
        
        mailTable.estimatedRowHeight = 45 + view.frame.width / 2
        mailTable.rowHeight = UITableViewAutomaticDimension
        
        mailTable.tableHeaderView = createTableHeader()
        mailTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        refreshData()
    }
    
    func formatButtons() {
        composeButton.setImage(UIImage(named: "reply")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        composeButton.tintColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTableHeader() -> UIView {
        let conversationList = conversation.conversationList()
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 30.0))
        headerView.backgroundColor = UIColor.whiteColor()
        let label = UILabel(frame: CGRect(x: 8.0, y: 5.0, width: view.frame.width - 16.0, height: 20.0))
        label.font = UIFont(name: "OpenSans-Light", size: 15.0)
        label.textColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1.0)
        label.text = conversationList
        label.numberOfLines = 0
        label.sizeToFit()
        let fixedHeight = label.frame.height
        headerView.addSubview(label)
        headerView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: fixedHeight + 10.0)
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: headerView.frame.height - width, width:  view.frame.width, height: headerView.frame.height)
        
        border.borderWidth = width
        headerView.layer.addSublayer(border)
        headerView.layer.masksToBounds = true
        
        return headerView
    }
    
    
    // Mark: Set up Core Data
    func initializeFetchedResultsController() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let fetchRequest = NSFetchRequest(entityName: "Mail")
        let statusSort = NSSortDescriptor(key: "status", ascending: false)
        let dateScheduledSort = NSSortDescriptor(key: "scheduledToArrive", ascending: false)
        let predicate = NSPredicate(format: "conversation.id == %@", conversation.id)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [statusSort, dateScheduledSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: "status", cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.name
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
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
            let sections = fetchedResultsController.sections!
            let sectionInfo = sections[section]
            if sectionInfo.numberOfObjects == 0 {
                return 0.0
            }
        case 1:
            let sections = fetchedResultsController.sections!
            let sectionInfo = sections[section]
            if sectionInfo.numberOfObjects == 0  {
                return 0.0
            }
        default:
            return 34.0
        }
        return 34.0
    }
    
    // MARK: Row configuration
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mailCell", forIndexPath: indexPath) as! ConversationMailCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ConversationMailCell, indexPath: NSIndexPath) {
        let mail = fetchedResultsController.objectAtIndexPath(indexPath) as! Mail
        cell.mail = mail
        cell.imageFile = nil
        cell.mailImageView.image = nil
        
        generateStatusLabel(cell, mail: cell.mail)
        
        addImageToCell(cell)
        if cell.imageFile != nil {
            cell.mailImageView.image = cell.imageFile
            cell.mailImageView.contentMode = .ScaleAspectFill
        }
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
    
    func addImageToCell(cell: ConversationMailCell) {
        cell.mail.getImage({error, result -> Void in
            if let image = result as? UIImage {
                cell.imageFile = image
            }
        })
    }
    
    func generateStatusLabel(cell: ConversationMailCell, mail: Mail) {
        if mail.status == "SENT" {
            let sentString = mail.dateSent.formattedAsString("yyyy-MM-dd")
            cell.statusLabel.text = "Sent on \(sentString)"
        }
        else {
            let deliveredString = mail.dateDelivered.formattedAsString("yyyy-MM-dd")
            cell.statusLabel.text = "Delivered on \(deliveredString)"
        }
    }
    
    func formatMailStatusLabel(cell: ConversationMailCell) {
        if cell.mail.toLoggedInUser() == true {
            if cell.mail.myStatus != "READ" {
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
        refreshData()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mail = fetchedResultsController.objectAtIndexPath(indexPath) as! Mail
        let storyboard = UIStoryboard(name: "mail", bundle: nil)
        let mailViewController = storyboard.instantiateInitialViewController() as! MailViewController
        mailViewController.mail = mail
        mailViewController.runOnClose = {self.refreshData()}
        presentViewController(mailViewController, animated: true, completion: {})
    }
    
    func refreshData() {
        MailService.updateAllData( { error, result -> Void in
            if result as? String == "Success" {
                self.mailTable.reloadData()
            }
            else {
                print(error)
            }
        })
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        mailTable.reloadData()
    }
    
    
    @IBAction func composeMessage(sender: AnyObject) {
        Flurry.logEvent("Clicked_compose_from_conversation_view")
        var toPeople = [Person]()
        let userId = LoginService.getUserIdFromToken()
        for item in conversation.people.allObjects {
            let person = item as! Person
            if person.id != userId {
                toPeople.append(person)
            }
        }
        var toEmails = [String]()
        for item in conversation.emails.allObjects {
            let emailAddress = item as! EmailAddress
            toEmails.append(emailAddress.email)
        }
        
        let storyboard = UIStoryboard(name: "compose", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ComposeNavigationController!
        controller.toPeople = toPeople
        controller.toSearchPeople = [SearchPerson]()
        controller.toEmails = toEmails
        presentViewController(controller, animated: true, completion: {})
    }

}
