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
    var segmentedControl: UISegmentedControl!
    
    let indexTitles = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
    
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
        initializeSegmentedControl()
        initializePeopleController()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        addSearchBar()
        addSegmentedControlToHeader()

        toPeople = [Person]()
        toEmails = [String]()
        validateNextButton()
    
        Flurry.logEvent("Compose_Message_Workflow_Began")
        
        warningLabel.hide()
        noResultsLabel.hidden = true
        personTable.sectionIndexColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        personTable.sectionHeaderHeight = 24.0
        
    }
    
    // Add search bar
    func addSearchBar() {
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.searchBarStyle = .Minimal
        self.navigationItem.titleView = self.searchController.searchBar
        self.definesPresentationContext = true
        
        let textField = searchController.searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        textField.textColor = UIColor.whiteColor()
        let attributedString = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        //Get the glass icon
        let iconView:UIImageView = textField.leftView as! UIImageView
        iconView.image = iconView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        iconView.tintColor = UIColor.whiteColor()
        
        textField.attributedPlaceholder = attributedString
        
    }
    
    func initializeSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Slowpost", "Everyone"])
        segmentedControl.tintColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
        segmentedControl.selectedSegmentIndex = 1
    }

    func addSegmentedControlToHeader() {
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.personTable.bounds.size.width, height: 40.0))
        headerView.backgroundColor = UIColor.whiteColor()
        headerView.addSubview(segmentedControl)
        let horizontalConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .CenterX, relatedBy: .Equal, toItem: headerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .CenterY, relatedBy: .Equal, toItem: headerView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint])
        self.personTable.tableHeaderView = headerView
        segmentedControl.addTarget(self, action:"toggleResults", forControlEvents: .ValueChanged)
    }
    
    // Mark: Set up Core Data
    
    func initializePeopleController() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let nameLetterSort = NSSortDescriptor(key: "nameLetter", ascending: true)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        
        let userId = LoginService.getUserIdFromToken()
        
        let slowpostPredicate = NSPredicate(format: "id != %@", userId)
        var startingPredicate:NSCompoundPredicate!
        if segmentedControl.selectedSegmentIndex == 0 {
            startingPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [slowpostPredicate])
        }
        else {
            let phonePredicate = NSPredicate(format: "origin != %@", "Postoffice")
            startingPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [slowpostPredicate, phonePredicate])
        }
        
        var finalPredicate:NSCompoundPredicate!
        if !searchTextEntered {
            finalPredicate = startingPredicate
        }
        else {
            let searchPredicate = NSPredicate(format: "name contains[c] %@", searchController.searchBar.text!)
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startingPredicate, searchPredicate])
        }
        
        fetchRequest.predicate = finalPredicate
        fetchRequest.sortDescriptors = [nameLetterSort, nameSort]
        
        peopleController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: "nameLetter", cacheName: nil)
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
    
    //MARK: segmented control configuration
    func toggleResults() {
        initializePeopleController()
        personTable.reloadData()
    }
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return peopleController.sections!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = self.peopleController.sections!
        let sectionInfo = sections[section]
        let title = sectionInfo.name
        return title
    }
 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = peopleController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return indexTitles
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "OpenSans-Semibold", size: 13)
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        let peopleIndex = peopleController.sectionIndexTitles.indexOf(title)
        if peopleIndex != nil {
            return peopleIndex!
        }
        else {
            var i = index + 1
            while i < indexTitles.count {
                let nextTitle = indexTitles[i]
                let nextIndex = peopleController.sectionIndexTitles.indexOf(nextTitle)
                if nextIndex != nil {
                    return nextIndex!
                }
                else {
                    i += 1
                }
            }
            let lastIndex = peopleController.sectionIndexTitles.count - 1
            return lastIndex
        }
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
        cell.tintColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        
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
        if personEmailSelected(person) != "" {
            cell.accessoryType = .Checkmark
            
        }
        else {
            cell.accessoryType = .None
        }
        cell.tintColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
    }
    
    func personEmailSelected(person: Person) -> String {
        let selectedSet = Set(toEmails)
        var personEmails = [String]()
        for object in person.emails.allObjects {
            let emailAddress = object as! EmailAddress
            personEmails.append(emailAddress.email)
        }
        let personSet = Set(personEmails)
        if selectedSet.intersect(personSet).count > 0 {
            return Array(selectedSet)[0]
        }
        else {
            return ""
        }
    }
    
    func configureEmailLabel(cell: PhoneContactCell) {
        if cell.person.emails.count == 1 {
            let emailAddress = cell.person.emails.allObjects[0] as! EmailAddress
            cell.emailLabel.text = emailAddress.email
        }
        else {
            let email = personEmailSelected(cell.person)
            if email == "" {
                cell.emailLabel.text = "multiple emails..."
            }
            else {
                cell.emailLabel.text = "multiple emails (\(email))"
            }
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
            if cell.person.emails.count == 1 {
                if personEmailSelected(cell.person) == "" {
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
                if self.searchController.isBeingPresented() {
                    self.dismissViewControllerAnimated(true, completion: {})
                }
                self.performSegueWithIdentifier("viewPhoneContact", sender: cell)
            }
        }
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
        validateNextButton()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        Flurry.logEvent("Compose_Cancelled")
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func validateNextButton() {
        if toPeople.count > 0 || toEmails.count > 0 {
            nextButton.hidden = false
        }
        else {
            nextButton.hidden = true
        }
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
            let email = personEmailSelected(cell.person)
            if email != "" {
                let personEmails = cell.person.emails.allObjects as! [EmailAddress]
                let emailSelected = personEmails.filter() {$0.email == personEmailSelected(cell.person) }[0]
                phoneContactViewController.emailSelected = emailSelected
            }
        }
    }
    
    @IBAction func emailAddressSelected(segue:UIStoryboardSegue) {
        if let contactView = segue.sourceViewController as? PhoneContactViewController {
            clearSelectedEmailsForPerson(contactView.person)
            toEmails.append(contactView.emailSelected.email)
            personTable.reloadData()
            validateNextButton()
        }
    }
    
    func clearSelectedEmailsForPerson(person: Person) {
        let email = personEmailSelected(person)
        if email != "" {
            toEmails = toEmails.filter() {$0 != email }
        }
    }
    
    @IBAction func cancelledWithNoEmailSelected(segue:UIStoryboardSegue) {
        if let contactView = segue.sourceViewController as? PhoneContactViewController {
            clearSelectedEmailsForPerson(contactView.person)
            if contactView.emailSelected != nil {
                toEmails.append(contactView.emailSelected.email)
            }
            personTable.reloadData()
            validateNextButton()
        }
    }
    
}
