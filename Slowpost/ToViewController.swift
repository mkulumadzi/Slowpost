//
//  ToViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 6/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ToViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate {

    var toPeople:[Person]!
    var toEmails:[String]!
    
    var peopleController: NSFetchedResultsController!
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var personTable: UITableView!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 240, 20))
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializePeopleController()
        
        toPeople = [Person]()
        toEmails = [String]()
    
        Flurry.logEvent("Compose_Message_Workflow_Began")
        
        warningLabel.hide()
        noResultsLabel.hidden = true
        
        self.personTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.personTable.bounds.size.width, height: 0.01))
        
    }
    
    // Mark: Set up Core Data
    
    func initializePeopleController() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        
        let userId = LoginService.getUserIdFromToken()
        let predicate1 = NSPredicate(format: "id != %@", userId)
        let predicate2 = NSPredicate(format: "origin != %@", "Postoffice")
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
        fetchRequest.sortDescriptors = [nameSort]
        
        peopleController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        peopleController.delegate = self
        do {
            try peopleController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return peopleController.sections!.count
    }
 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = peopleController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "Slowpost Penpals"
//        case 1:
//            return "Phone Contacts"
//        default:
//            return nil
//        }
//    }
    
//    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel!.textColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0)
//        header.textLabel!.font = UIFont(name: "OpenSans-Semibold", size: 15)
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 34.0
//    }

    // MARK: Row configuration
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let person = peopleController.objectAtIndexPath(indexPath) as! Person
        if !person.id.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("personCell", forIndexPath: indexPath) as! PersonCell
            self.configurePersonCell(cell, indexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("phoneContactCell", forIndexPath: indexPath) as! PhoneContactCell
            self.configurePhoneContactCell(cell, indexPath: indexPath)
            return cell
        }
    }
    
    func configurePersonCell(cell: PersonCell, indexPath: NSIndexPath) {
        
        let person = peopleController.objectAtIndexPath(indexPath) as! Person
        cell.person = person
        cell.personNameLabel.text = person.name
        cell.avatarView.layer.cornerRadius = 15
        cell.avatarInitials.text = person.initials()
        if cell.checked == nil {
            cell.checked = false
            cell.accessoryType = .None
        }
        else if cell.checked == true {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
    }
    
    func configurePhoneContactCell(cell: PhoneContactCell, indexPath: NSIndexPath) {
        
        let person = peopleController.objectAtIndexPath(indexPath) as! Person
        cell.person = person
        cell.personNameLabel.text = person.name
        cell.avatarView.layer.cornerRadius = 15
        cell.avatarView.backgroundColor = UIColor.whiteColor()
        cell.avatarView.layer.borderColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0).CGColor
        cell.avatarView.layer.borderWidth = 1.0
        cell.avatarImageView.layer.cornerRadius = 15
        configureEmailLabel(cell)
        if cell.checked == nil {
            cell.checked = false
            cell.accessoryType = .None
        }
        else if cell.checked == true {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
    }
    
    func configureEmailLabel(cell: PhoneContactCell) {
        if cell.person.emails.count == 1 {
            let emailAddress = cell.person.emails.allObjects[0] as! EmailAddress
            cell.emailLabel.text = emailAddress.email
        }
        else {
            cell.emailLabel.text = "multiple emails..."
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let person = peopleController.objectAtIndexPath(indexPath) as! Person
        switch person.id.isEmpty {
        case false:
            let cell = personTable.cellForRowAtIndexPath(indexPath) as! PersonCell
            if cell.checked == false {
                cell.checked = true
                cell.accessoryType = .Checkmark
                toPeople.append(cell.person)
                print(toPeople)
            }
            else {
                cell.checked = false
                cell.accessoryType = .None
                toPeople = toPeople.filter() {$0.id != cell.person.id}
                print(toPeople)
            }
        default:
            let cell = personTable.cellForRowAtIndexPath(indexPath) as! PhoneContactCell
            if cell.checked == false {
                cell.checked = true
                cell.accessoryType = .Checkmark
                if cell.person.emails.count == 1 {
                    let emailAddress = cell.person.emails.allObjects[0] as! EmailAddress
                    toEmails.append(emailAddress.email)
                }
            }
            else {
                cell.checked = false
                cell.accessoryType = .None
            }
            
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        Flurry.logEvent("Compose_Cancelled")
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("selectImage", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectImage" {
            let chooseImageViewController = segue.destinationViewController as? ChooseImageViewController
            chooseImageViewController?.toPeople = toPeople
            chooseImageViewController?.toEmails = toEmails
        }
    }
    
}
