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

class ConversationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var conversationList: UITableView!
//    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var messageLabel: MessageUILabel!
    
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
        initializeFetchedResultsController()
        
        messageLabel.hide()
        conversationList.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: conversationList.bounds.size.width, height: 0.01))
        ConversationService.updateConversations()
        conversationList.addSubview(self.refreshControl)
//        addSearchBar()
        
//        noResultsLabel.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        ConversationService.updateConversations()
    }
    
//    func addSearchBar() {
//        let textField = searchBar.valueForKey("searchField") as! UITextField
//        textField.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
//        textField.textColor = UIColor.whiteColor()
//        let attributedString = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
//        
//        //Get the glass icon
//        let iconView:UIImageView = textField.leftView as! UIImageView
//        iconView.image = iconView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        iconView.tintColor = UIColor.whiteColor()
//        
//        textField.attributedPlaceholder = attributedString
//        
//        searchBar.delegate = self
//        
//        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
//        self.navigationItem.leftBarButtonItem = leftNavBarButton
//        
//        ////Can't get this to work...
//        //        let horizontalConstraint = NSLayoutConstraint(item: self.navigationItem.leftBarButtonItem!, attribute: .TrailingMargin, relatedBy: .Equal, toItem: searchBar, attribute: .Left, multiplier: 1.0, constant: 10)
//        //
//        //        view.addConstraint(horizontalConstraint)
//    }
    
    
    // Mark: Set up Core Data
    func initializeFetchedResultsController() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        let updatedSort = NSSortDescriptor(key: "updatedAt", ascending: false)
        fetchRequest.sortDescriptors = [updatedSort]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    
    func handleRefresh(refreshControl: UIRefreshControl) {
        ConversationService.updateConversations()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        
////        conversationMetadataList = conversationMetadataArray
//        
//        if self.searchBar.text!.isEmpty == false {
//            
//            let newMetadataArray:[ConversationMetadata] = conversationMetadataList.filter() {
//                self.listMatches(self.searchBar.text!, inString: $0.username).count >= 1 || self.listMatches(self.searchBar.text!, inString: $0.name).count >= 1
//            }
//            conversationMetadataList = newMetadataArray
//        }
//        
////        validateNoResultsLabel()
//        self.conversationList.reloadData()
//    }
    
//    func listMatches(pattern: String, inString string: String) -> [String] {
//        let regex = try? NSRegularExpression(pattern: pattern, options: [])
//        let range = NSMakeRange(0, string.characters.count)
//        let matches = regex?.matchesInString(string, options: [], range: range)
//        return matches!.map {
//            let range = $0.range
//            return (string as NSString).substringWithRange(range)
//        }
//    }
    
//    func validateNoResultsLabel() {
//        if searchBar.text == "" {
//            noResultsLabel.hidden = true
//        }
//        else if penpalList.count == 0 {
//            noResultsLabel.hidden = false
//        }
//        else {
//            noResultsLabel.hidden = true
//        }
//    }
    
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        searchBar.resignFirstResponder()
//    }
    
    // MARK: Section Configuration
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = self.fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as? ConversationCell
        
//        let conversationMetadata = conversationMetadataList[indexPath.row] as ConversationMetadata
        let conversation = fetchedResultsController.objectAtIndexPath(indexPath) as! Conversation
        cell?.conversation = conversation
        cell?.namesLabel.text = conversation.peopleNames()
        
        formatConversationCellLabel(cell!)
        
        return cell!
    }
    
    func formatConversationCellLabel(cell: ConversationCell) {
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewConversation" {
            if let conversationCell = sender as? ConversationCell {
                let conversationViewController = segue.destinationViewController as? ConversationViewController
                conversationViewController!.conversation = conversationCell.conversation
            }
        }
    }
    
//    func getPersonForCell(conversationCell: ConversationCell) -> Person {
//        let person = penpals.filter({$0.username == conversationCell.conversationMetadata.username})[0]
//        return person
//    }
    
    @IBAction func settingsMenuItemSelected(segue:UIStoryboardSegue) {
        dismissSourceViewController(segue)
        if segue.identifier == "editPasswordSelected" {
            self.performSegueWithIdentifier("editPassword", sender: nil)
        }
        else if segue.identifier == "editProfileSelected" {
            self.performSegueWithIdentifier("editProfile", sender: nil)
        }
    }
    
    @IBAction func cancelToConversationViewController(segue:UIStoryboardSegue) {
        dismissSourceViewController(segue)
        Flurry.logEvent("Cancelled_Back_To_Conversation_View")
    }
    
    @IBAction func completeEditingAndReturnToConversationViewController(segue:UIStoryboardSegue) {
        dismissSourceViewController(segue)
    }
    
    @IBAction func choseToLogOut(segue:UIStoryboardSegue) {
        dismissSourceViewController(segue)
        LoginService.logOut()
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func dismissSourceViewController(segue: UIStoryboardSegue) {
        if !segue.sourceViewController.isBeingDismissed() {
            segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
