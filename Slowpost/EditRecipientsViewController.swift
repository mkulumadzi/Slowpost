//
//  EditRecipientsViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 10/23/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit
import Foundation

class EditRecipientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!

    @IBOutlet weak var recipientsTable: UITableView!
    @IBOutlet weak var recipientsTableHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableHeight()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: recipientsTable.bounds.size.width, height: 40.0))
        headerView.backgroundColor = slowpostDarkGreen
        let headerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: recipientsTable.bounds.size.width, height: 40.0))
        headerLabel.textAlignment = .Center
        headerLabel.text = "Recipients"
        headerLabel.font = UIFont(name: "OpenSans-Semibold", size: 15.0)
        headerLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func setTableHeight() {
        let numRows = (toPeople.count + toSearchPeople.count + toEmails.count)
        recipientsTableHeight.constant = CGFloat(numRows * 44) + 40.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = toPeople.count + toSearchPeople.count + toEmails.count
        return numRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recipientCell", forIndexPath: indexPath) as! RecipientCell
        if indexPath.row < toPeople.count {
            let person = toPeople[indexPath.row]
            configureRecipientCell(cell, object: person)
            return cell
        }
        else if indexPath.row < (toSearchPeople.count + toPeople.count) {
            let adjustedIndex = indexPath.row - toPeople.count
            let searchPerson = toSearchPeople[adjustedIndex]
            configureRecipientCell(cell, object: searchPerson)
            return cell
        }
        else {
            let adjustedIndex = indexPath.row - (toPeople.count + toSearchPeople.count)
            let email = toEmails[adjustedIndex]
            configureRecipientCell(cell, object: email)
            return cell
        }
    }
    
    func configureRecipientCell(cell: RecipientCell, object: AnyObject) {
        if let person = object as? Person {
            cell.person = person
            cell.recipientLabel.text = "\(person.fullName()) (@\(person.username))"
        }
        else if let searchPerson = object as? SearchPerson {
            cell.searchPerson = searchPerson
            cell.recipientLabel.text = "\(searchPerson.fullName()) (@\(searchPerson.username))"
        }
        else if let email = object as? String {
            cell.email = email
            cell.recipientLabel.text = cell.email
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }


}
