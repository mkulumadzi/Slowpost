//
//  MyMailboxViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class MyMailboxViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mailTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Mailbox_opened")
        initializeFetchedResultsController()
        configure()
        refreshData()
    }
    
    //MARK: Setup
    
    private func configure() {
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        mailTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: mailTable.bounds.size.width, height: 0.01))
        mailTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        mailTable.addSubview(refreshControl)
        
        mailTable.estimatedRowHeight = 85 + (view.frame.width - 20) * 0.75
        mailTable.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserverForName("imageDownloaded:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            self.mailTable.reloadData()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("appBecameActive:", object: nil, queue: nil, usingBlock: { (notification) -> Void in
            let token = LoginService.getTokenFromKeychain()
            if token != nil {
                self.refreshData()
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        mailTable.reloadData()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval)
    {
        mailTable.reloadData()
    }
    
    // Mark: Set up Core Data
    func initializeFetchedResultsController() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        
        let fetchRequest = NSFetchRequest(entityName: "Mail")
        let deliveredSort = NSSortDescriptor(key: "dateDelivered", ascending: false)
    
        let userId = LoginService.getUserIdFromToken()
        let predicate = NSPredicate(format: "ANY toPeople.id == %@", userId)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [deliveredSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        mailTable.reloadData()
    }
    
    //MARK: Table setup
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as! MailCell
        configureCell(cell, indexPath: indexPath)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mail = fetchedResultsController.objectAtIndexPath(indexPath) as! Mail
        let storyboard = UIStoryboard(name: "mail", bundle: nil)
        let mailViewController = storyboard.instantiateInitialViewController() as! MailViewController
        mailViewController.mail = mail
        mailViewController.runOnClose = {self.refreshData()}
        presentViewController(mailViewController, animated: true, completion: {})
    }
    
    private func configureCell(cell: MailCell, indexPath: NSIndexPath) {
        
        let mail = fetchedResultsController.objectAtIndexPath(indexPath) as! Mail
        cell.mail = mail
        cell.mailImage.image = nil
        cell.imageFile = nil
        
        let fromPerson = mail.fromPerson
        cell.fromViewInitials.text = fromPerson.initials()
        cell.fromLabel.text = fromPerson.fullName()
        addImageToCell(cell)
        if let imageFile = cell.imageFile {
            cell.mailImage.image = imageFile
            cell.mailImage.contentMode = .ScaleAspectFill
        }
        let deliveredDateString = mail.dateDelivered.formattedAsString("yyyy-MM-dd")
        cell.deliveredLabel.text = "Delivered on \(deliveredDateString)"
        formatMailCellBasedOnMailStatus(cell, mail: mail)
        
    }
    
    private func addImageToCell(cell: MailCell) {
        cell.mail.getImage({error, result -> Void in
            if let image = result as? UIImage {
                cell.imageFile = image
            }
        })
    }
    
    private func formatMailCellBasedOnMailStatus(cell: MailCell, mail: Mail) {
        if mail.myStatus == "READ" {
            cell.fromLabel.font = UIFont(name: "OpenSans-Regular", size: 17.0)
            cell.statusIndicator.backgroundColor = UIColor.whiteColor()
            cell.statusIndicator.layer.borderColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0).CGColor
            cell.statusIndicator.layer.borderWidth = 1.0
            
        }
        else {
            cell.fromLabel.font = UIFont(name: "OpenSans-Semibold", size: 17.0)
            cell.statusIndicator.backgroundColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
            cell.statusIndicator.layer.borderWidth = 0.0
        }
    }
    
    //MARK: Private
    
    private func handleRefresh(refreshControl: UIRefreshControl) {
        refreshData()
        refreshControl.endRefreshing()
    }
    
    private func refreshData() {
        MailService.updateAllData( { error, result -> Void in
            if let error = error { print(error) }
        })
    }


}
