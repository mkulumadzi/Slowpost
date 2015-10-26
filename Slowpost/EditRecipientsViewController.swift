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
    
    var toPeopleSelectedAtIndex:[Bool]!
    var toSearchPeopleSelectedAtIndex:[Bool]!
    var toEmailsSelectedAtIndex:[Bool]!

    @IBOutlet weak var recipientsTable: UITableView!
    @IBOutlet weak var recipientsTableHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableHeight()
        initializeSelectedIndices()
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
    
    func initializeSelectedIndices() {
        toPeopleSelectedAtIndex = [Bool]()
        toSearchPeopleSelectedAtIndex = [Bool]()
        toEmailsSelectedAtIndex = [Bool]()
        for _ in toPeople {
            toPeopleSelectedAtIndex.append(true)
        }
        for _ in toSearchPeople {
            toSearchPeopleSelectedAtIndex.append(true)
        }
        for _ in toEmails {
            toEmailsSelectedAtIndex.append(true)
        }
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
            if toPeopleSelectedAtIndex[indexPath.row] == true {
                cell.accessoryType = .Checkmark
            }
            return cell
        }
        else if indexPath.row < (toSearchPeople.count + toPeople.count) {
            let adjustedIndex = indexPath.row - toPeople.count
            let searchPerson = toSearchPeople[adjustedIndex]
            configureRecipientCell(cell, object: searchPerson)
            if toSearchPeopleSelectedAtIndex[adjustedIndex] == true {
                cell.accessoryType = .Checkmark
            }
            return cell
        }
        else {
            let adjustedIndex = indexPath.row - (toPeople.count + toSearchPeople.count)
            let email = toEmails[adjustedIndex]
            configureRecipientCell(cell, object: email)
            if toEmailsSelectedAtIndex[adjustedIndex] == true {
                cell.accessoryType = .Checkmark
            }
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
        let cell = recipientsTable.cellForRowAtIndexPath(indexPath) as! RecipientCell
        if indexPath.row < toPeople.count {
            if toPeopleSelectedAtIndex[indexPath.row] == true {
                toPeopleSelectedAtIndex[indexPath.row] = false
                cell.accessoryType = .None
            }
            else {
                toPeopleSelectedAtIndex[indexPath.row] = true
                cell.accessoryType = .Checkmark
            }
        }
        else if indexPath.row < (toSearchPeople.count + toPeople.count) {
            let adjustedIndex = indexPath.row - toPeople.count
            if toSearchPeopleSelectedAtIndex[adjustedIndex] == true {
                toSearchPeopleSelectedAtIndex[adjustedIndex] = false
                cell.accessoryType = .None
            }
            else {
                toSearchPeopleSelectedAtIndex[adjustedIndex] = true
                cell.accessoryType = .Checkmark
            }
            
        }
        else {
            let adjustedIndex = indexPath.row - (toPeople.count + toSearchPeople.count)
            if toEmailsSelectedAtIndex[adjustedIndex] == true {
                toEmailsSelectedAtIndex[adjustedIndex] = false
                cell.accessoryType = .None
            }
            else {
                toEmailsSelectedAtIndex[adjustedIndex] = true
                cell.accessoryType = .Checkmark
            }
        }
        recipientsTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        performSegueWithIdentifier("recipientsEdited", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "recipientsEdited" {
            clearDeselectedRecipients()
            if let toViewController = segue.destinationViewController as? ToViewController {
                toViewController.toPeople = toPeople
                toViewController.toSearchPeople = toSearchPeople
                toViewController.toEmails = toEmails
            }
        }
    }
    
    func clearDeselectedRecipients() {
        var updatedPeople = [Person]()
        var updatedSearchPeople = [SearchPerson]()
        var updatedEmails = [String]()
        
        var i = 0
        while i < toPeople.count {
            if toPeopleSelectedAtIndex[i] == true {
                updatedPeople.append(toPeople[i])
            }
            i += 1
        }
        toPeople = updatedPeople
        
        i = 0
        while i < toSearchPeople.count {
            if toSearchPeopleSelectedAtIndex[i] == true {
                updatedSearchPeople.append(toSearchPeople[i])
            }
           i += 1
        }
        toSearchPeople = updatedSearchPeople
        
        i = 0
        while i < toEmails.count {
            if toEmailsSelectedAtIndex[i] == true {
                updatedEmails.append(toEmails[i])
            }
            i += 1
        }
        toEmails = updatedEmails
    }


}
