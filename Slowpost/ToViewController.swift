//
//  ToViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 6/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ToViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var toPerson:Person!
    var penpalList: [Person] = []
    var contactsList: [Person] = []
    var otherUsersList: [Person] = []
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var toPersonList: UITableView!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 240, 20))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Compose_Message_Workflow_Began")
        
        reloadPenpals()

        warningLabel.hide()
        noResultsLabel.hidden = true
        
        addSearchBar()
        
        self.toPersonList.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.toPersonList.bounds.size.width, height: 0.01))
        
        penpalList = penpals.filter({$0.username != loggedInUser.username})
        contactsList = registeredContacts.filter({$0.username != loggedInUser.username})
        excludePenpalsFromContactsList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addSearchBar() {
        searchBar.placeholder = "To: Name or Username"
        searchBar.tintColor = UIColor.lightGrayColor()
        
        var rightNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightNavBarButton
        
        searchBar.delegate = self
        
        ////Can't get this to work...
//        let horizontalConstraint = NSLayoutConstraint(item: self.navigationItem.leftBarButtonItem!, attribute: .TrailingMargin, relatedBy: .Equal, toItem: searchBar, attribute: .Left, multiplier: 1.0, constant: 10)
//        
//        view.addConstraint(horizontalConstraint)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        penpalList = penpals.filter({$0.username != loggedInUser.username})
        contactsList = registeredContacts.filter({$0.username != loggedInUser.username})
        excludePenpalsFromContactsList()
        
        if self.searchBar.text.isEmpty == false {
            
            var newPenpalArray:[Person] = penpalList.filter() {
                self.listMatches(self.searchBar.text, inString: $0.username).count >= 1 || self.listMatches(searchBar.text, inString: $0.name).count >= 1
            }
            penpalList = newPenpalArray
            
            var newContactsArray:[Person] = contactsList.filter() {
                self.listMatches(self.searchBar.text, inString: $0.username).count >= 1 || self.listMatches(searchBar.text, inString: $0.name).count >= 1
            }
            contactsList = newContactsArray
            
            if penpalList.count == 0 {
                noResultsLabel.hidden = true
                self.searchPeople(self.searchBar.text)
            }
            
        }
        else {
            toPerson = nil
            otherUsersList = []
        }
        
        validateNoResultsLabel()
        warningLabel.hide()
        self.toPersonList.reloadData()
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
    
    func validateNoResultsLabel() {
        if searchBar.text == "" {
            noResultsLabel.hidden = true
        }
        else if penpalList.count == 0 && contactsList.count == 0 && otherUsersList.count == 0 {
            noResultsLabel.hidden = false
        }
        else {
            noResultsLabel.hidden = true
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if penpalList.count > 0 {
                return "Penpals"
            }
        case 1:
            if contactsList.count > 0 {
                return "Your address book"
            }
        case 2:
            if otherUsersList.count > 0 {
                return "People on Slowpost"
            }
        default:
            return nil
        }
        return nil
    }
 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return penpalList.count
        case 1:
            return contactsList.count
        case 2:
            return otherUsersList.count
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
        header.textLabel.font = UIFont(name: "OpenSans-Semibold", size: 15)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if penpalList.count == 0 {
                return 0.0
            }
        case 1:
            if contactsList.count == 0 {
                return 0.0
            }
        case 2:
            if otherUsersList.count == 0 {
                return 0.0
            }
        default:
            return 34.0
        }
        return 34.0

    }

    // MARK: Row configuration
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personCell", forIndexPath: indexPath) as? PersonCell
        
        switch indexPath.section {
        case 0:
            if penpalList.count > 0 {
                let person = penpalList[indexPath.row] as Person
                cell?.personNameLabel.text = person.name
                cell?.usernameLabel.text = "@" + person.username
            }
        case 1:
            if contactsList.count > 0 {
                let person = contactsList[indexPath.row] as Person
                cell?.personNameLabel.text = person.name
                cell?.usernameLabel.text = "@" + person.username
            }
        case 2:
            let person = otherUsersList[indexPath.row] as Person
            cell?.personNameLabel.text = person.name
            cell?.usernameLabel.text = "@" + person.username
        default:
            cell?.personNameLabel.text = ""
            cell?.usernameLabel.text = ""
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            if penpalList.count > 0 {
                Flurry.logEvent("Penpal_Selected")
                let person = penpalList[indexPath.row] as Person
                searchBar.text = person.username
                toPerson = person
                self.performSegueWithIdentifier("selectImage", sender: nil)
            }
        case 1:
            if contactsList.count > 0 {
                Flurry.logEvent("Contact_Selected")
                let person = contactsList[indexPath.row] as Person
                searchBar.text = person.username
                toPerson = person
                self.performSegueWithIdentifier("selectImage", sender: nil)
            }
        case 2:
            Flurry.logEvent("Other_User_Selected")
            let person = otherUsersList[indexPath.row] as Person
            searchBar.text = person.username
            toPerson = person
            self.performSegueWithIdentifier("selectImage", sender: nil)
        default:
            toPerson = nil
        }
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        Flurry.logEvent("Compose_Cancelled")
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func searchPeople(term: String) {
        
        var searchResults = [Person]()
    
        var searchTerm = RestService.normalizeSearchTerm(searchBar.text)
        let searchPeopleURL = "\(PostOfficeURL)people/search?term=\(searchTerm)&limit=10"
        
        PersonService.getPeopleCollection(searchPeopleURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let peopleArray = result as? Array<Person> {
                self.otherUsersList = peopleArray
                self.excludeContactsFromOtherList()
                self.toPersonList.reloadData()
                self.validateNoResultsLabel()
            }
        })
    }
    
    func reloadPenpals() {
        
        //Get all 'penpal' records whom the user has sent mail to or received mail from
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
    
    func excludePenpalsFromContactsList() {
        for penpal in penpalList {
            var i = 0
            for contact in contactsList {
                if penpal.username == contact.username {
                    contactsList.removeAtIndex(i)
                }
                else {
                    i += 1
                }
            }
        }
    }
    
    func excludeContactsFromOtherList() {
        for contact in contactsList {
            var i = 0
            for other in otherUsersList {
                if contact.username == other.username {
                    otherUsersList.removeAtIndex(i)
                }
                else {
                    i += 1
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectImage" {
            let chooseImageViewController = segue.destinationViewController as? ChooseImageViewController
            chooseImageViewController?.toPerson = toPerson
        }
    }
    
}
