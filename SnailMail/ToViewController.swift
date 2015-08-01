//
//  ToViewController.swift
//  SnailMail
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
    
    @IBOutlet weak var toSearchField: UISearchBar!
    @IBOutlet weak var toPersonList: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadPenpals()

        warningLabel.hide()
        
        validateNextButton()
        
        penpalList = penpals.filter({$0.username != loggedInUser.username})
        contactsList = registeredContacts.filter({$0.username != loggedInUser.username})
        excludePenpalsFromContactsList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        penpalList = penpals.filter({$0.username != loggedInUser.username})
        contactsList = registeredContacts.filter({$0.username != loggedInUser.username})
        excludePenpalsFromContactsList()
        
        if self.toSearchField.text.isEmpty == false {
            
            var newPenpalArray:[Person] = penpalList.filter() {
                self.listMatches(self.toSearchField.text, inString: $0.username).count >= 1 || self.listMatches(self.toSearchField.text, inString: $0.name).count >= 1
            }
            penpalList = newPenpalArray
            
            var newContactsArray:[Person] = contactsList.filter() {
                self.listMatches(self.toSearchField.text, inString: $0.username).count >= 1 || self.listMatches(self.toSearchField.text, inString: $0.name).count >= 1
            }
            contactsList = newContactsArray
            
            if penpalList.count == 0 {
                self.searchPeople(self.toSearchField.text)
            }
            
        }
        else {
            toPerson = nil
            otherUsersList = []
        }
        
        validateNextButton()
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
    
    func validateNextButton() {
        if toPerson == nil {
            nextButton.enabled = false
        }
        else {
            nextButton.enabled = true
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if penpalList.count > 0 || contactsList.count > 0 {
            return 2
        }
        else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Your penpals"
        case 1:
            return "Other contacts on Snailtale"
        case 2:
            return "Other users"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if penpalList.count > 0 {
                return penpalList.count
            }
            else {
                return 1
            }
        case 1:
            if contactsList.count > 0 {
                return contactsList.count
            }
            else {
                return 1
            }
        case 2:
            return otherUsersList.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personCell", forIndexPath: indexPath) as? PersonCell
        
        switch indexPath.section {
        case 0:
            if penpalList.count > 0 {
                let person = penpalList[indexPath.row] as Person
                cell?.personNameLabel.text = person.name
                cell?.usernameLabel.text = "@" + person.username
            }
            else {
                cell?.personNameLabel.text = ""
                cell?.usernameLabel.text = "No results"
            }
        case 1:
            if contactsList.count > 0 {
                let person = contactsList[indexPath.row] as Person
                cell?.personNameLabel.text = person.name
                cell?.usernameLabel.text = "@" + person.username
            }
            else {
                cell?.personNameLabel.text = ""
                cell?.usernameLabel.text = "No results"
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
                let person = penpalList[indexPath.row] as Person
                toSearchField.text = person.username
                toPerson = person
                self.performSegueWithIdentifier("selectImage", sender: nil)
            }
        case 1:
            if contactsList.count > 0 {
                let person = contactsList[indexPath.row] as Person
                toSearchField.text = person.username
                toPerson = person
                self.performSegueWithIdentifier("selectImage", sender: nil)
            }
        case 2:
            let person = otherUsersList[indexPath.row] as Person
            toSearchField.text = person.username
            toPerson = person
            self.performSegueWithIdentifier("selectImage", sender: nil)
        default:
            toPerson = nil
        }
        
        validateNextButton()
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.lightGrayColor()
        header.textLabel.textColor = UIColor.blackColor()
        header.textLabel.font = UIFont(name: "OpenSans-Semibold", size: 15)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "home", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func searchPeople(term: String) {
        
        var searchResults = [Person]()
    
        var searchTerm = RestService.normalizeSearchTerm(toSearchField.text)
        let searchPeopleURL = "\(PostOfficeURL)people/search?term=\(searchTerm)&limit=10"
        
        PersonService.getPeopleCollection(searchPeopleURL, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let peopleArray = result as? Array<Person> {
                self.otherUsersList = peopleArray
                self.toPersonList.reloadData()
            }
        })
    }
    
    func reloadPenpals() {
        
        //Get all 'penpal' records whom the user has sent mail to or received mail from
        let contactsURL = "\(PostOfficeURL)person/id/\(loggedInUser.id)/contacts"
        PersonService.getPeopleCollection(contactsURL, completion: { (error, result) -> Void in
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
    
    @IBAction func selectImage(sender: AnyObject) {
        self.performSegueWithIdentifier("selectImage", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectImage" {
            let chooseImageViewController = segue.destinationViewController as? ChooseImageViewController
            chooseImageViewController?.toPerson = toPerson
        }
    }
    
}
