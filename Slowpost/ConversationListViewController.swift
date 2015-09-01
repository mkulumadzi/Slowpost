//
//  ConversationListViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ConversationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var penpalList: [Person] = []
    
    @IBOutlet weak var conversationList: UITableView!
//    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var messageLabel: MessageUILabel!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 240, 20))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Conversation_View_Opened")
        messageLabel.hide()
        conversationList.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: conversationList.bounds.size.width, height: 0.01))
        reloadPenpals()
        conversationList.addSubview(self.refreshControl)
        addSearchBar()
        
//        noResultsLabel.hidden = true
        
        println(conversationMetadataArray)
        penpalList = penpals.filter({$0.username != loggedInUser.username})
    }
    
    func addSearchBar() {
        var textField = searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        textField.textColor = UIColor.whiteColor()
        var attributedString = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        //Get the glass icon
        var iconView:UIImageView = textField.leftView as! UIImageView
        iconView.image = iconView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        iconView.tintColor = UIColor.whiteColor()
        
        textField.attributedPlaceholder = attributedString
        
        searchBar.delegate = self
        
        var leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        ////Can't get this to work...
        //        let horizontalConstraint = NSLayoutConstraint(item: self.navigationItem.leftBarButtonItem!, attribute: .TrailingMargin, relatedBy: .Equal, toItem: searchBar, attribute: .Left, multiplier: 1.0, constant: 10)
        //
        //        view.addConstraint(horizontalConstraint)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        reloadPenpals()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        penpalList = penpals.filter({$0.username != loggedInUser.username})
        
        if self.searchBar.text.isEmpty == false {
            
            var newPenpalArray:[Person] = penpalList.filter() {
                self.listMatches(self.searchBar.text, inString: $0.username).count >= 1 || self.listMatches(self.searchBar.text, inString: $0.name).count >= 1
            }
            penpalList = newPenpalArray
            
        }
        
//        validateNoResultsLabel()
        self.conversationList.reloadData()
    }
    
    func listMatches(pattern: String, inString string: String) -> [String] {
        let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: nil)
        let range = NSMakeRange(0, count(string))
        let matches = regex?.matchesInString(string, options: .allZeros, range: range) as! [NSTextCheckingResult]
        
        return matches.map {
            let range = $0.range
            return (string as NSString).substringWithRange(range)
        }
    }
    
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return penpalList.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as? ConversationCell
        
        let person = penpalList[indexPath.row] as Person
        cell?.person = person
        cell?.personNameLabel.text = person.name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Flurry.logEvent("Conversation_Opened")
    }
    
    func reloadPenpals() {
        
        let contactsURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/contacts"
        PersonService.getPeopleCollection(contactsURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let peopleArray = result as? Array<Person> {
                penpals = peopleArray
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewConversation" {
            if let conversationCell = sender as? ConversationCell {
                let conversationViewController = segue.destinationViewController as? ConversationViewController
                conversationViewController!.person = conversationCell.person
            }
        }
    }
    
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
