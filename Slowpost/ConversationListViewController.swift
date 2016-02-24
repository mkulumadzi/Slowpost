//
//  ConversationListViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ConversationListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var conversationList: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 240, 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Conversation_View_Opened")
        configure()
        refreshData()
    }
    
    //MARK: Setup
    
    private func configure() {
        formatButtons()
        initializeFetchedResultsController()
        addMessageLabel()
        conversationList.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: conversationList.bounds.size.width, height: 0.01))
        conversationList.addSubview(refreshControl)
    }
    
    private func formatButtons() {
        settingsButton.setImage(UIImage(named: "settings")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        settingsButton.tintColor = UIColor.whiteColor()
    }
    
    func refreshData() {
        MailService.updateAllData( { error, result -> Void in
            if result as? String == "Success" {
                self.conversationList.reloadData()
            }
            else {
                print(error)
            }
        })
    }
    
    // Mark: Set up Core Data
    private func initializeFetchedResultsController() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        let updatedSort = NSSortDescriptor(key: "updatedAt", ascending: false)
        fetchRequest.sortDescriptors = [updatedSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshData()
        refreshControl.endRefreshing()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.conversationList.reloadData()
    }
    
    
    // MARK: Section Configuration
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as? ConversationCell
        let conversation = fetchedResultsController.objectAtIndexPath(indexPath) as! Conversation
        cell?.conversation = conversation
        cell?.namesLabel.text = conversation.conversationList()
        
        formatConversationCellLabel(cell!)
        
        return cell!
    }
    
    private func formatConversationCellLabel(cell: ConversationCell) {
        
        for view in cell.subviews {
            if let cellLabel = view as? CellLabelUIView {
                if cell.conversation.numUnread > 0 {
                    cellLabel.backgroundColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
                    cellLabel.layer.borderWidth = 0.0
                }
                else if cell.conversation.numUndelivered > 0 {
                    cellLabel.backgroundColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
                    cellLabel.layer.borderWidth = 0.0
                }
                else if cell.conversation.personSentMostRecentMail == true {
                    cellLabel.backgroundColor = UIColor.whiteColor()
                    cellLabel.layer.borderColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0).CGColor
                    cellLabel.layer.borderWidth = 1.0
                }
                else {
                    cellLabel.backgroundColor = UIColor.whiteColor()
                    cellLabel.layer.borderColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0).CGColor
                    cellLabel.layer.borderWidth = 1.0
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Flurry.logEvent("Conversation_Opened")
    }
    
    //MARK: User actions
    
    @IBAction func settingsMenuItemSelected(segue:UIStoryboardSegue) {
        dismissSourceViewController(segue)
        if segue.identifier == "editPasswordSelected" {
            performSegueWithIdentifier("editPassword", sender: nil)
        }
        else if segue.identifier == "editProfileSelected" {
            performSegueWithIdentifier("editProfile", sender: nil)
        }
    }
    
    @IBAction func cancelToConversationViewController(segue:UIStoryboardSegue) {
        Flurry.logEvent("Cancelled_Back_To_Conversation_View")
    }
    
    @IBAction func completeEditingAndReturnToConversationViewController(segue:UIStoryboardSegue) {
    }
    
    @IBAction func choseToLogOut(segue:UIStoryboardSegue) {
        LoginService.logOut()
        dismissViewControllerAnimated(true, completion: {})
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewConversation" {
            if let conversationCell = sender as? ConversationCell {
                let conversationViewController = segue.destinationViewController as? ConversationViewController
                conversationViewController!.conversation = conversationCell.conversation
            }
        }
    }
    
    //MARK: Private
    
    func dismissSourceViewController(segue: UIStoryboardSegue) {
        if !segue.sourceViewController.isBeingDismissed() {
            segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
