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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toList = people
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        toList = people
        
        if self.toSearchField.text.isEmpty == false {
            var newArray:[Person] = toList.filter() {
                self.listMatches(self.toSearchField.text, inString: $0.username).count >= 1 || self.listMatches(self.toSearchField.text, inString: $0.name).count >= 1
            }
            toList = newArray
        }
        
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
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectImage" {
            let chooseCardViewController = segue.destinationViewController as? ChooseCardViewController
            if let to = toUsername {
                chooseCardViewController?.toUsername = to
            }
            else {
                chooseCardViewController?.toUsername = toSearchField.text
            }
        }
    }
    
}
