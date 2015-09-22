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

class MyMailboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mailTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var fetchedResultsController: NSFetchedResultsController!
    
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
        
        initializeFetchedResultsController()
        
        refreshData()
        
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
            self.refreshData()
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
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    //
    
    func configureCell(cell: MailCell, indexPath: NSIndexPath) {
        
        let mail = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Mail
        cell.mail = mail
        
        let fromPerson = mail.fromPerson
        cell.fromViewInitials.text = fromPerson.initials()
        cell.fromLabel.text = fromPerson.name
//        cell.imageView!.image = mail.image()
        let deliveredDateString = mail.dateDelivered.formattedAsString("yyyy-MM-dd")
        cell.deliveredLabel.text = "Delivered on \(deliveredDateString)"
        formatMailCellBasedOnMailStatus(cell, mail: mail)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as! MailCell
        self.configureCell(cell, indexPath: indexPath)
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
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshData()
        refreshControl.endRefreshing()
    }
    
    func refreshData() {
        PersonService.updatePeople()
        MailService.updateMailbox()
        mailTable.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mail = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Mail
        let storyboard = UIStoryboard(name: "mail", bundle: nil)
        let mailViewController = storyboard.instantiateInitialViewController() as! MailViewController
        mailViewController.mail = mail
        mailViewController.runOnClose = {self.refreshData()}
        
        self.presentViewController(mailViewController, animated: true, completion: {})
    }


}
