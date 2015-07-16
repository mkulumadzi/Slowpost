//
//  ToViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire


class ToViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var toUsername:String!
    var penpalList: [Person] = []
    var otherUsersList: [Person] = []
    
    @IBOutlet weak var toSearchField: UISearchBar!
    @IBOutlet weak var toPersonList: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(registeredContacts)
        
        reloadPenpals()

        warningLabel.hide()
        
        validateNextButton()
        penpalList = penpals.filter({$0.username != loggedInUser.username})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        penpalList = penpals.filter({$0.username != loggedInUser.username})
        
        if self.toSearchField.text.isEmpty == false {
            
            toUsername = self.toSearchField.text
            var newArray:[Person] = penpalList.filter() {
                self.listMatches(self.toSearchField.text, inString: $0.username).count >= 1 || self.listMatches(self.toSearchField.text, inString: $0.name).count >= 1
            }
            penpalList = newArray
            
            if penpalList.count == 0 {
                self.searchPeople(self.toSearchField.text)
            }
            
        }
        else {
            toUsername = nil
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
        if toUsername == nil {
            nextButton.enabled = false
        }
        else {
            nextButton.enabled = true
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if penpalList.count > 0 {
            return 1
        }
        else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Your SnailTale contacts"
        case 1:
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
            let person = penpalList[indexPath.row] as Person
            toSearchField.text = person.username
            toUsername = person.username
        case 1:
            let person = otherUsersList[indexPath.row] as Person
            toSearchField.text = person.username
            toUsername = person.username
        default:
            toUsername = nil
        }
        
        validateNextButton()
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func selectImage(sender: AnyObject) {
        self.performSegueWithIdentifier("selectImage", sender: nil)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectImage" {
            let chooseCardViewController = segue.destinationViewController as? ChooseCardViewController
            chooseCardViewController?.toUsername = toUsername
        }
    }
    
    func searchPeople(term: String) {
        
        var searchResults = [Person]()
    
        DataManager.searchPeople(toSearchField.text, completion: { (error, result) -> Void in
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
        DataManager.getPenpals(loggedInUser.id, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let peopleArray = result as? Array<Person> {
                penpals = peopleArray
            }
        })
    }
    
}
