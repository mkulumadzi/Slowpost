//
//  PhoneContactViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 9/29/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class PhoneContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var person:Person!
    var emailSelected:EmailAddress!
    var checkedIndexPath:NSIndexPath!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var emailAddressTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddressTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: emailAddressTable.bounds.size.width, height: 0.01))
        name.text = person.fullName()
        formatButtons()

    }
    
    func formatButtons() {
        cancelButton.setImage(UIImage(named: "close")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        cancelButton.tintColor = slowpostDarkGrey
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if emailSelected == nil {
            performSegueWithIdentifier("emailCleared", sender: nil)
        }
        else {
            dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return person.emails.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("emailAddress", forIndexPath: indexPath) as! EmailAddressTableViewCell
        let emailAddress = person.emails.allObjects[indexPath.row] as! EmailAddress
        cell.emailAddress = emailAddress
        cell.emailAddressLabel.text = emailAddress.email
        if emailSelected != nil && emailSelected == cell.emailAddress {
            cell.checked = true
            cell.accessoryType = .Checkmark
            checkedIndexPath = indexPath
        }
        else {
            cell.checked = false
            cell.accessoryType = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = emailAddressTable.cellForRowAtIndexPath(indexPath) as! EmailAddressTableViewCell
        if cell.checked == true {
            cell.checked = false
            cell.accessoryType = .None
            emailSelected = nil
        }
        else {
            clearCheckMark()
            cell.checked = true
            cell.accessoryType = .Checkmark
            emailSelected = cell.emailAddress
            performSegueWithIdentifier("emailAddressSelected", sender: cell)
        }
    }
    
    func clearCheckMark() {
        if checkedIndexPath != nil {
            let cell = emailAddressTable.cellForRowAtIndexPath(checkedIndexPath) as! EmailAddressTableViewCell
            cell.checked = false
            cell.accessoryType = .None
        }
    }

}
