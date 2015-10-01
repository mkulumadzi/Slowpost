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

class ToViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate , UISearchControllerDelegate, UISearchResultsUpdating {

    var toPeople:[Person]!
    var toEmails:[String]!
    var searchTextEntered:Bool!
    
    var peopleController: NSFetchedResultsController!
    var searchController: UISearchController!
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var personTable: UITableView!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextEntered = false
        initializePeopleController()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsCancelButton = false
        self.personTable.tableHeaderView = searchController.searchBar
    
        
        toPeople = [Person]()
        toEmails = [String]()
    
        Flurry.logEvent("Compose_Message_Workflow_Began")
        
        warningLabel.hide()
        noResultsLabel.hidden = true
        
//        self.personTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.personTable.bounds.size.width, height: 0.01))
        
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
        let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1, predicate2])
        var finalPredicate:NSCompoundPredicate!
        
        if !searchTextEntered {
            finalPredicate = orPredicate
        }
        else {
            let predicate3 = NSPredicate(format: "name contains[c] %@", searchController.searchBar.text!)
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [orPredicate, predicate3])
        }
        
        fetchRequest.predicate = finalPredicate
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
        searchController.searchBar.resignFirstResponder()
    }
    
    //MARK: search configuration
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            searchTextEntered = false
        }
        else {
            searchTextEntered = true
        }
        
        initializePeopleController()
        personTable.reloadData()
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
        cell.usernameLabel.text = "@\(person.username)"
        cell.avatarView.layer.cornerRadius = 15
        cell.avatarInitials.text = person.initials()
        if personSelected(person) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
    }
    
    func personSelected(person: Person) -> Bool {
        let filter = toPeople.filter() {$0.id == person.id}
        if filter.count > 0 {
            return true
        }
        return false
    }
    
    func configurePhoneContactCell(cell: PhoneContactCell, indexPath: NSIndexPath) {
        
        let person = peopleController.objectAtIndexPath(indexPath) as! Person
        cell.person = person
        cell.personNameLabel.text = person.name
        cell.avatarView.layer.cornerRadius = 15
        cell.avatarView.backgroundColor = UIColor.whiteColor()
        cell.avatarView.layer.borderColor = UIColor(red: 127/255, green: 122/255, blue: 122/255, alpha: 1.0).CGColor
        cell.avatarView.layer.borderWidth = 1.0
        configureEmailLabel(cell)
        if personEmailSelected(person) {
            cell.accessoryType = .Checkmark
//            cell.checked = true
        }
        else {
            cell.accessoryType = .None
//            cell.checked = false
        }
    }
    
    func personEmailSelected(person: Person) -> Bool {
        let selectedSet = Set(toEmails)
        var personEmails = [String]()
        for object in person.emails.allObjects {
            let emailAddress = object as! EmailAddress
            personEmails.append(emailAddress.email)
        }
        let personSet = Set(personEmails)
        if selectedSet.intersect(personSet).count > 0 {
            return true
        }
        else {
            return false
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
            if !personSelected(cell.person) {
                cell.accessoryType = .Checkmark
                toPeople.append(cell.person)
            }
            else {
                cell.accessoryType = .None
                toPeople = toPeople.filter() {$0.id != cell.person.id}
            }
        default:
            let cell = personTable.cellForRowAtIndexPath(indexPath) as! PhoneContactCell
            cell.indexPath = indexPath
            if cell.person.emails.count == 1 {
                if !personEmailSelected(cell.person) {
                    cell.accessoryType = .Checkmark
                    if cell.person.emails.count == 1 {
                        let emailAddress = cell.person.emails.allObjects[0] as! EmailAddress
                        toEmails.append(emailAddress.email)
                    }
                }
                else {
                    cell.accessoryType = .None
                    let emailAddress = cell.person.emails.allObjects[0] as! EmailAddress
                    toEmails = toEmails.filter() {$0 != emailAddress.email }
                }
            }
            else {
                self.performSegueWithIdentifier("viewPhoneContact", sender: cell)
            }
        }
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
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
        if segue.identifier == "viewPhoneContact" {
            let cell = sender as! PhoneContactCell
            let phoneContactViewController = segue.destinationViewController as! PhoneContactViewController
            phoneContactViewController.person = cell.person
            phoneContactViewController.indexPath = cell.indexPath
            if personEmailSelected(cell.person) { phoneContactViewController.emailSelected = cell.emailAddress }
        }
    }
    
    @IBAction func emailAddressSelected(segue:UIStoryboardSegue) {
        if let contactView = segue.sourceViewController as? PhoneContactViewController {
            let updateCell = personTable.cellForRowAtIndexPath(contactView.indexPath) as! PhoneContactCell
            if updateCell.emailAddress != nil {
                toEmails = toEmails.filter() {$0 != updateCell.emailAddress.email }
            }
            updateCell.emailLabel.text = "multiple (\(contactView.emailSelected.email))"
            updateCell.emailAddress = contactView.emailSelected
            toEmails.append(contactView.emailSelected.email)
            updateCell.accessoryType = .Checkmark
        }
    }
    
    @IBAction func cancelledWithNoEmailSelected(segue:UIStoryboardSegue) {
        if let contactView = segue.sourceViewController as? PhoneContactViewController {
            let updateCell = personTable.cellForRowAtIndexPath(contactView.indexPath) as! PhoneContactCell
            updateCell.emailLabel.text = "multiple emails..."
            toEmails = toEmails.filter() {$0 != updateCell.emailAddress.email }
            updateCell.emailAddress = nil
            updateCell.accessoryType = .None
        }
    }
    
}
