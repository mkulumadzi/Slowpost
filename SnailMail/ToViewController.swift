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
    var toList: [Person] = []
    
    @IBOutlet weak var toSearchField: UISearchBar!
    @IBOutlet weak var toPersonList: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningLabel.hide()
        
        validateNextButton()
        toList = people.filter({$0.username != loggedInUser.username})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        toList = people
        
        if self.toSearchField.text.isEmpty == false {
            toUsername = self.toSearchField.text
            var newArray:[Person] = toList.filter() {
                self.listMatches(self.toSearchField.text, inString: $0.username).count >= 1 || self.listMatches(self.toSearchField.text, inString: $0.name).count >= 1
            }
            toList = newArray
        }
        else {
            toUsername = nil
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personCell", forIndexPath: indexPath) as? PersonCell
        
        let person = toList[indexPath.row] as Person
        cell?.personNameLabel.text = person.name
        cell?.usernameLabel.text = person.username
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let person = toList[indexPath.row] as Person
        
        toSearchField.text = person.username
        toUsername = person.username
        validateNextButton()
        
    }
    
    func isValidUsername(username: String) -> Bool {
        
        //This RegEx validates whether the username is a valid email.
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if usernameTest.evaluateWithObject(username) == true {
            return true
        } else {
            return false
        }

    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func selectImage(sender: AnyObject) {
        
        if isValidUsername(toUsername) {
            self.performSegueWithIdentifier("selectImage", sender: nil)
        } else {
            warningLabel.show("Recipient must be registered user or valid email address.")
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectImage" {
            let chooseCardViewController = segue.destinationViewController as? ChooseCardViewController
            chooseCardViewController?.toUsername = toUsername
        }
    }
    
}
