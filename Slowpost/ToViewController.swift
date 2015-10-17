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
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    
    var searchTextEntered:Bool!
    var searchResults:[SearchPerson]!
    
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    var peopleController: NSFetchedResultsController!
    var searchController: UISearchController!
    var segmentedControl: UISegmentedControl!
    
    let indexTitles = [">", "#", "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","?"]
    
    @IBOutlet weak var personTable: UITableView!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Compose_Message_Workflow_Began")
        toPeople = [Person]()
        toSearchPeople = [SearchPerson]()
        toEmails = [String]()
        searchResults = [SearchPerson]()
        
        searchTextEntered = false
        initializeSegmentedControl()
        initializePeopleController()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        addSearchBar()
        addSegmentedControlToHeader()

        validateNextButton()
        
        warningLabel.hide()
        personTable.sectionIndexColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        personTable.sectionIndexBackgroundColor = UIColor.clearColor()
        personTable.sectionHeaderHeight = 24.0
        
    }
    
    // Add search bar
    func addSearchBar() {
        let view = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0)
        )
        view.backgroundColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
        self.view.addSubview(view)
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.searchBarStyle = .Minimal

        self.navigationItem.titleView = self.searchController.searchBar
        self.definesPresentationContext = true
        
        let textField = searchController.searchBar.valueForKey("searchField") as! UITextField
        textField.textColor = UIColor.whiteColor()
        let attributedString = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        textField.clearButtonMode = .Never
        
        //Get the glass icon
        let iconView:UIImageView = textField.leftView as! UIImageView
        iconView.image = iconView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        iconView.tintColor = UIColor.whiteColor()
        
        textField.attributedPlaceholder = attributedString
        
    }
    
    func initializeSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Slowpost", "Everyone"])
        segmentedControl.tintColor = UIColor(red:0/255, green: 182/255, blue: 185/255, alpha: 1.0)
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.layer.cornerRadius = 4
        segmentedControl.selectedSegmentIndex = 0
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
        let familyNameSort = NSSortDescriptor(key: "familyName", ascending: true)
        
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
            let searchGivenNamePredicate = NSPredicate(format: "givenName contains[c] %@", searchController.searchBar.text!)
            let searchFamilyNamePredicate = NSPredicate(format: "familyName contains[c] %@", searchController.searchBar.text!)
            //To Do: Search given name and family name if space is entered
            let searchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [searchGivenNamePredicate, searchFamilyNamePredicate])
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startingPredicate, searchPredicate])
        }
        
        fetchRequest.predicate = finalPredicate
        fetchRequest.sortDescriptors = [nameLetterSort, familyNameSort]
        
        peopleController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.moc, sectionNameKeyPath: "nameLetter", cacheName: nil)
        peopleController.delegate = self
        do {
            try peopleController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func searchPeopleOnSlowpost(term: String) {
        let searchTerm = RestService.normalizeSearchTerm(searchController.searchBar.text!)
        let searchPeopleURL = "\(PostOfficeURL)people/search?term=\(searchTerm)&limit=10"
        
        SearchPersonService.searchPeople(searchPeopleURL, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else if let peopleArray = result as? [SearchPerson] {
                if peopleArray.count > 0 {
                    if self.toSearchPeople.count == 0 {
                        self.searchResults = peopleArray
                        self.personTable.reloadData()
                    }
                    else {
                        self.filterSelectedPeopleFromSearchResults(peopleArray)
                    }
                }
                else {
                    self.searchResults = [SearchPerson]()
                }
            }
        })
    }
    
    func filterSelectedPeopleFromSearchResults(results:[SearchPerson]) {
        var selectedIds = [String]()
        for selectedPerson in toSearchPeople {
            selectedIds.append(selectedPerson.id)
        }
        var filteredResults = [SearchPerson]()
        for person in results {
            if selectedIds.indexOf(person.id) == nil {
                filteredResults.append(person)
            }
        }
        searchResults = filteredResults
        personTable.reloadData()
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
            searchResults = [SearchPerson]()
        }
        else {
            if searchController.searchBar.text!.characters.count > 2 {
                searchPeopleOnSlowpost(searchController.searchBar.text!)
            }
            searchTextEntered = true
        }

        
        initializePeopleController()
        personTable.reloadData()
    }
    
    //MARK: segmented control configuration
    func toggleResults() {
        Flurry.logEvent("Toggled_list_of_people")
        initializePeopleController()
        personTable.reloadData()
    }
    
    // MARK: Section Configuration
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numSections:Int = peopleController.sections!.count
        if recipientSection() == true {
            numSections += 1
        }
        if otherSection() == true {
            numSections += 1
        }
        return numSections
    }
    
    func recipientSection() -> Bool {
        if (toPeople.count + toSearchPeople.count + toEmails.count) > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func otherSection() -> Bool {
        if searchTextEntered == true {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let peopleSections = self.peopleController.sections!
        var adjustedSection:Int!
        if recipientSection() == true {
            adjustedSection = section - 1
            if section == 0 {
                return "Recipients (tap to deselect)"
            }
        }
        else {
            adjustedSection = section
        }
        if adjustedSection < peopleSections.count {
            let sectionInfo = peopleSections[adjustedSection]
            let title = sectionInfo.name
            return title
        }
        else {
            return "Other people"
        }
    }
 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let peopleSections = peopleController.sections!
        var adjustedSection:Int!
        if recipientSection() == true {
            adjustedSection = section - 1
            if section == 0 {
                return (toPeople.count + toSearchPeople.count + toEmails.count)
            }
        }
        else {
            adjustedSection = section
        }
        if adjustedSection < peopleSections.count {
            let sectionInfo = peopleSections[adjustedSection]
            return sectionInfo.numberOfObjects
        }
        else {
            return (searchResults.count + 1)
        }
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
    
    // Come back to this...
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
        var adjustedIndexPath:NSIndexPath!
        if recipientSection() == false {
            adjustedIndexPath = indexPath
        }
        else {
            adjustedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1)
            if indexPath.section == 0 {
                let cell = cellForRecipient(tableView, indexPath: indexPath)
                return cell
            }
        }
        let peopleSections = peopleController.sections!
        if adjustedIndexPath.section < peopleSections.count {
            let cell = cellForPerson(tableView, indexPath: adjustedIndexPath)
            return cell
        }
        else {
            let cell = otherCell(tableView, indexPath: indexPath)
            return cell
        }
    }
    
    func cellForRecipient(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recipientCell", forIndexPath: indexPath) as! RecipientCell
        if indexPath.row < toPeople.count {
            let person = toPeople[indexPath.row]
            self.configureRecipientCell(cell, object: person)
            return cell
        }
        else if indexPath.row < (toSearchPeople.count + toPeople.count) {
            let adjustedIndex = indexPath.row - toPeople.count
            let searchPerson = toSearchPeople[adjustedIndex]
            self.configureRecipientCell(cell, object: searchPerson)
            return cell
        }
        else {
            let adjustedIndex = indexPath.row - (toPeople.count + toSearchPeople.count)
            let email = toEmails[adjustedIndex]
            self.configureRecipientCell(cell, object: email)
            return cell
        }
    }
    
    func cellForPerson(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let person = peopleController.objectAtIndexPath(indexPath) as! Person
        if !person.id.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("personCell") as! PersonCell
            cell.person = person
            self.configurePersonCell(cell)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("phoneContactCell") as! PhoneContactCell
            cell.person = person
            self.configurePhoneContactCell(cell)
            return cell
        }
    }
    
    func otherCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < searchResults.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchPersonCell") as! SearchPersonCell
            cell.searchPerson = searchResults[indexPath.row]
            self.configureSearchPersonCell(cell)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("manualEmailCell")!
            return cell
        }
    }
    
    func configurePersonCell(cell: PersonCell) {
        cell.personNameLabel.text = cell.person.fullName()
        cell.usernameLabel.text = "@\(cell.person.username)"
        cell.cellImage.image = UIImage(named: "Slowpost.png")
        cell.cellImage.layer.cornerRadius = 10
        if personSelected(cell.person) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        cell.tintColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        
    }
    
    func configureSearchPersonCell(cell: SearchPersonCell) {
        cell.nameLabel.text = cell.searchPerson.fullName()
        cell.usernameLabel.text = "@\(cell.searchPerson.username)"
        cell.cellImage.image = UIImage(named: "Slowpost.png")
        cell.cellImage.layer.cornerRadius = 10
        cell.tintColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
    }
    
    func configureRecipientCell(cell: RecipientCell, object: AnyObject) {
        if let person = object as? Person {
            cell.person = person
            cell.cellImage.image = UIImage(named: "Slowpost.png")
            cell.cellImage.layer.cornerRadius = 10
            cell.recipientLabel.text = "\(person.fullName()) (@\(person.username))"
            cell.labelLeadingDistance.constant = 31
        }
        else if let searchPerson = object as? SearchPerson {
            cell.searchPerson = searchPerson
            cell.cellImage.image = UIImage(named: "Slowpost.png")
            cell.cellImage.layer.cornerRadius = 10
            cell.recipientLabel.text = "\(searchPerson.fullName()) (@\(searchPerson.username))"
            cell.labelLeadingDistance.constant = 31
        }
        else if let email = object as? String {
            cell.cellImage.image = nil
            cell.email = email
            cell.recipientLabel.text = cell.email
            cell.labelLeadingDistance.constant = 8
        }
    }
    
    func personSelected(person: Person) -> Bool {
        let filter = toPeople.filter() {$0.id == person.id}
        if filter.count > 0 {
            return true
        }
        return false
    }
    
    func configurePhoneContactCell(cell: PhoneContactCell) {
        cell.personNameLabel.text = cell.person.fullName()
        configureEmailLabel(cell)
        if personEmailSelected(cell.person) != "" {
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
        var adjuster:Int = 0
        if self.recipientSection() == true {
            adjuster = 1
        }
        let numPeopleSections = peopleController.sections!.count
        if recipientSection() == true && indexPath.section == 0 {
            Flurry.logEvent("Removed_recipient")
            self.removeRecipient(tableView, indexPath: indexPath)
        }
        else if (indexPath.section - adjuster) < numPeopleSections {
            self.handlePersonSelection(tableView, indexPath: indexPath)
        }
        else {
            self.handleOtherSelection(tableView, indexPath: indexPath)
        }
        self.searchController.dismissViewControllerAnimated(true, completion: {})
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
        validateNextButton()
        let topRect = CGRect(x: 0.0, y: 0.0, width: personTable.frame.width, height: personTable.frame.height)
        personTable.scrollRectToVisible(topRect, animated: false)
        formatNextLabel()
    }
    
    func removeRecipient(tableView: UITableView, indexPath: NSIndexPath) {
        if indexPath.row < toPeople.count {
            toPeople.removeAtIndex(indexPath.row)
        }
        else if indexPath.row < (toPeople.count + toSearchPeople.count) {
            let adjustedIndex = indexPath.row - toPeople.count
            toSearchPeople.removeAtIndex(adjustedIndex)
        }
        else {
            let adjustedIndex = indexPath.row - (toPeople.count + toSearchPeople.count)
            toEmails.removeAtIndex(adjustedIndex)
        }
    }
    
    func handlePersonSelection(tableView: UITableView, indexPath: NSIndexPath) {
        if let cell = personTable.cellForRowAtIndexPath(indexPath) as? PersonCell {
            if !personSelected(cell.person) {
                Flurry.logEvent("Added_person")
                cell.accessoryType = .Checkmark
                toPeople.append(cell.person)
            }
            else {
                Flurry.logEvent("Removed_person")
                cell.accessoryType = .None
                toPeople = toPeople.filter() {$0.id != cell.person.id}
            }
        }
        else if let cell = personTable.cellForRowAtIndexPath(indexPath) as? PhoneContactCell {
            if cell.person.emails.count == 1 {
                if personEmailSelected(cell.person) == "" {
                    Flurry.logEvent("Added_email")
                    cell.accessoryType = .Checkmark
                    if cell.person.emails.count == 1 {
                        let emailAddress = cell.person.emails.allObjects[0] as! EmailAddress
                        toEmails.append(emailAddress.email)
                    }
                }
                else {
                    Flurry.logEvent("Removed_email")
                    cell.accessoryType = .None
                    let emailAddress = cell.person.emails.allObjects[0] as! EmailAddress
                    toEmails = toEmails.filter() {$0 != emailAddress.email }
                }
            }
            else {
                self.searchController.dismissViewControllerAnimated(true, completion: {})
                self.performSegueWithIdentifier("viewPhoneContact", sender: cell)
            }
        }
        else {
            print("Did not recognize cell")
        }
    }
    
    func handleOtherSelection(tableView: UITableView, indexPath: NSIndexPath) {
        if let searchPersonCell = tableView.cellForRowAtIndexPath(indexPath) as? SearchPersonCell {
            Flurry.logEvent("Added_person_searched_on_slowpost")
            let searchPerson = searchPersonCell.searchPerson
            self.toSearchPeople.append(searchPerson)
            self.personTable.reloadData()
            self.validateNextButton()
        }
        else {
            self.searchController.dismissViewControllerAnimated(true, completion: {Void in
                self.performSegueWithIdentifier("addEmail", sender: nil)
            })
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        Flurry.logEvent("Compose_Cancelled")
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func validateNextButton() {
        if toPeople.count > 0 || toSearchPeople.count > 0 || toEmails.count > 0 {
            nextButtonHeight.constant = 40.0
        }
        else {
            nextButtonHeight.constant = 0.0
        }
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "compose", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ComposeNavigationController!
        controller.toPeople = toPeople
        controller.toSearchPeople = toSearchPeople
        controller.toEmails = toEmails
        self.presentViewController(controller, animated: true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
        Flurry.logEvent("Added_email_for_person_with_multiple")
        if let contactView = segue.sourceViewController as? PhoneContactViewController {
            clearSelectedEmailsForPerson(contactView.person)
            toEmails.append(contactView.emailSelected.email)
            personTable.reloadData()
            validateNextButton()
            formatNextLabel()
        }
    }
    
    @IBAction func emailAdded(segue:UIStoryboardSegue) {
        if let addEmailView = segue.sourceViewController as? AddEmailViewController {
            toEmails.append(addEmailView.emailField.text!)
            personTable.reloadData()
            validateNextButton()
            formatNextLabel()
        }
    }
    
    func clearSelectedEmailsForPerson(person: Person) {
        let email = personEmailSelected(person)
        if email != "" {
            toEmails = toEmails.filter() {$0 != email }
        }
    }
    
    @IBAction func cancelledWithNoEmailSelected(segue:UIStoryboardSegue) {
        Flurry.logEvent("Removed_email_for_person_with_multiple")
        if let contactView = segue.sourceViewController as? PhoneContactViewController {
            clearSelectedEmailsForPerson(contactView.person)
            if contactView.emailSelected != nil {
                toEmails.append(contactView.emailSelected.email)
            }
            personTable.reloadData()
            validateNextButton()
            formatNextLabel()
        }
    }
    
    func formatNextLabel() {
        let numSlowposts = toPeople.count + toSearchPeople.count
        let numEmails = toEmails.count
        var title:String?
        
        var slowpostString:String!
        if numSlowposts > 1 {
            slowpostString = "\(numSlowposts) on Slowpost"
        }
        else if numSlowposts > 0 {
            slowpostString = "\(numSlowposts) on Slowpost"
        }
        
        var emailString:String!
        if numEmails > 1 {
            emailString = "\(numEmails) emails"
        }
        else if numEmails > 0 {
            emailString = "\(numEmails) email"
        }
        
        if numSlowposts > 0 && numEmails > 0 {
            title = "Write to \(slowpostString) and \(emailString)"
        }
        else if numSlowposts > 0 {
            title = "Write to \(slowpostString)"
        }
        else if numEmails > 0 {
            title = "Write to \(emailString)"
        }
        else {
            title = ""
        }
        
        nextButton.setTitle(title, forState: .Normal)
        
    }
    
}
