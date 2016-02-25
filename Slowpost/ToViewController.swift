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

class ToViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate , UISearchControllerDelegate, UISearchResultsUpdating {

    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    var searchTextEntered:Bool!
    var searchResults:[SearchPerson]!
    var shadedView:UIView!
    var peopleController: NSFetchedResultsController!
    var searchController: UISearchController!
    var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableToBottomLayoutGuide: NSLayoutConstraint!
    @IBOutlet weak var personTable: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonArrows: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editRecipientsButton: UIButton!
    
    let indexTitles = [">", "#", "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Compose_Message_Workflow_Began")
        configure()
        validateNextButton()
    }
    
    //MARK: Setup
    
    private func configure() {
        personTable.sectionIndexColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        personTable.sectionIndexBackgroundColor = UIColor.clearColor()
        personTable.sectionHeaderHeight = 24.0
        toPeople = [Person]()
        toSearchPeople = [SearchPerson]()
        toEmails = [String]()
        searchResults = [SearchPerson]()
        searchTextEntered = false
        
        initializeSegmentedControl()
        initializeSearchController()
        initializePeopleController()
        addWarningLabel()
        addSearchBar()
        addSegmentedControlToHeader()
        formatButtons()
        initializeShadedView()
    }
    
    private func initializeSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    private func formatButtons() {
        cancelButton.setTintedImage("close", tintColor: UIColor.whiteColor())
        nextButton.contentHorizontalAlignment = .Right
    }
    
    private func initializeShadedView() {
        shadedView = UIView(frame: view.frame)
        shadedView.backgroundColor = slowpostBlack
        shadedView.alpha = 0.5
        view.addSubview(shadedView)
        shadedView.hidden = true
    }
    
    private func addSearchBar() {
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.searchBarStyle = .Minimal

        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        
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
    
    private func initializeSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Slowpost", "Everyone"])
        segmentedControl.tintColor = slowpostDarkGreen
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.layer.cornerRadius = 4
        segmentedControl.selectedSegmentIndex = 0
    }

    private func addSegmentedControlToHeader() {
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: personTable.bounds.size.width, height: 40.0))
        headerView.backgroundColor = UIColor.whiteColor()
        headerView.addSubview(segmentedControl)
        let horizontalConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .CenterX, relatedBy: .Equal, toItem: headerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: segmentedControl, attribute: .CenterY, relatedBy: .Equal, toItem: headerView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint])
        personTable.tableHeaderView = headerView
        segmentedControl.addTarget(self, action:"toggleResults", forControlEvents: .ValueChanged)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
    
    private func validateNextButton() {
        if toPeople.count > 0 || toSearchPeople.count > 0 || toEmails.count > 0 {
            nextButton.hidden = false
            nextButtonArrows.hidden = false
            editRecipientsButton.hidden = false
            tableToBottomLayoutGuide.constant = 60
        }
        else {
            nextButton.hidden = true
            nextButtonArrows.hidden = true
            editRecipientsButton.hidden = true
            tableToBottomLayoutGuide.constant = 0
        }
    }
    
    // Mark: Set up Core Data
    
    private func initializePeopleController() {
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
    
    func toggleResults() {
        Flurry.logEvent("Toggled_list_of_people")
        initializePeopleController()
        personTable.reloadData()
    }

    //MARK: Search controller configuration
    
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

    
    // MARK: Table view configuration
    
    // Table sections
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        header.textLabel!.font = UIFont(name: "OpenSans-Semibold", size: 13)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numSections = peopleController.sections!.count + 1
        return numSections
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let peopleSections = peopleController.sections!
        if section < peopleSections.count {
            let sectionInfo = peopleSections[section]
            let title = sectionInfo.name
            return title
        }
        else {
            return "Other people"
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return indexTitles
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        let peopleIndex = peopleController.sectionIndexTitles.indexOf(title)
        if let peopleIndex = peopleIndex {
            return peopleIndex
        }
        else {
            var i = index + 1
            while i < indexTitles.count {
                let nextTitle = indexTitles[i]
                if let nextIndex = peopleController.sectionIndexTitles.indexOf(nextTitle) {
                    return nextIndex
                }
                else {
                    i += 1
                }
            }
            let lastIndex = peopleController.sectionIndexTitles.count - 1
            return lastIndex
        }
    }
    

    // Table rows
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let peopleSections = peopleController.sections!
        if section < peopleSections.count {
            let sectionInfo = peopleSections[section]
            return sectionInfo.numberOfObjects
        }
        else {
            return (searchResults.count + 1)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let peopleSections = peopleController.sections!
        if indexPath.section < peopleSections.count {
            let cell = cellForPerson(tableView, indexPath: indexPath)
            return cell
        }
        else {
            let cell = otherCell(tableView, indexPath: indexPath)
            return cell
        }
    }
    
    private func cellForPerson(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let person = peopleController.objectAtIndexPath(indexPath) as! Person
        if !person.id.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("personCell") as! PersonCell
            cell.person = person
            configurePersonCell(cell)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("phoneContactCell") as! PhoneContactCell
            cell.person = person
            configurePhoneContactCell(cell)
            return cell
        }
    }
    
    private func otherCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < searchResults.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("searchPersonCell") as! SearchPersonCell
            cell.searchPerson = searchResults[indexPath.row]
            configureSearchPersonCell(cell)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("manualEmailCell")!
            return cell
        }
    }
    
    private func configurePersonCell(cell: PersonCell) {
        cell.personNameLabel.text = cell.person.fullName()
        cell.usernameLabel.text = "@\(cell.person.username)"
        cell.cellImage.image = UIImage(named: "Slowpost.png")
        cell.cellImage.layer.masksToBounds = true
        cell.cellImage.layer.cornerRadius = 10
        if personSelected(cell.person) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        cell.tintColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
        
    }
    
    private func configureSearchPersonCell(cell: SearchPersonCell) {
        cell.nameLabel.text = cell.searchPerson.fullName()
        cell.usernameLabel.text = "@\(cell.searchPerson.username)"
        cell.cellImage.image = UIImage(named: "Slowpost.png")
        cell.cellImage.layer.masksToBounds = true
        cell.cellImage.layer.cornerRadius = 10
        cell.tintColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
    }
    
    private func configurePhoneContactCell(cell: PhoneContactCell) {
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
        let numPeopleSections = peopleController.sections!.count
        if indexPath.section < numPeopleSections {
            handlePersonSelection(tableView, indexPath: indexPath)
        }
        else {
            handleOtherSelection(tableView, indexPath: indexPath)
        }
        
        searchController.dismissViewControllerAnimated(true, completion: {})
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
        validateNextButton()
        formatNextLabel()
    }
    
    private func handlePersonSelection(tableView: UITableView, indexPath: NSIndexPath) {
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
                searchController.dismissViewControllerAnimated(true, completion: {})
                performSegueWithIdentifier("viewPhoneContact", sender: cell)
            }
        }
        else {
            print("Did not recognize cell")
        }
    }
    
    private func handleOtherSelection(tableView: UITableView, indexPath: NSIndexPath) {
        if let searchPersonCell = tableView.cellForRowAtIndexPath(indexPath) as? SearchPersonCell {
            Flurry.logEvent("Added_person_searched_on_slowpost")
            let searchPerson = searchPersonCell.searchPerson
            toSearchPeople.append(searchPerson)
            personTable.reloadData()
            validateNextButton()
        }
        else {
            if searchController.isBeingPresented() {
                searchController.dismissViewControllerAnimated(true, completion: {Void in
                    self.performSegueWithIdentifier("addEmail", sender: nil)
                })
            }
            else {
                self.performSegueWithIdentifier("addEmail", sender: nil)
            }
        }
    }
    
    //MARK: User actions
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        Flurry.logEvent("Compose_Cancelled")
        dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "compose", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ComposeNavigationController!
        controller.toPeople = toPeople
        controller.toSearchPeople = toSearchPeople
        controller.toEmails = toEmails
        presentViewController(controller, animated: true, completion: {})
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
            if let email = contactView.emailSelected?.email {
                toEmails.append(email)
            }
            personTable.reloadData()
            validateNextButton()
            formatNextLabel()
        }
    }
    
    @IBAction func recipientsEdited(segue: UIStoryboardSegue) {
        shadedView.hidden = true
        formatNextLabel()
        validateNextButton()
        personTable.reloadData()
    }
    
    @IBAction func editRecipientsCancelled(segue: UIStoryboardSegue) {
        shadedView.hidden = true
    }
    
    //MARK: Segues
    
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
        else if segue.identifier == "editRecipients" {
            shadedView.hidden = false
            let editRecipientsViewController = segue.destinationViewController as! EditRecipientsViewController
            editRecipientsViewController.toPeople = toPeople
            editRecipientsViewController.toSearchPeople = toSearchPeople
            editRecipientsViewController.toEmails = toEmails
        }
    }
    
    //MARK: Private
    
    private func searchPeopleOnSlowpost(term: String) {
        let searchTerm = RestService.normalizeSearchTerm(searchController.searchBar.text!)
        let searchPeopleURL = "\(PostOfficeURL)people/search?term=\(searchTerm)&limit=10"
        
        SearchPersonService.searchPeople(searchPeopleURL, completion: { (error, result) -> Void in
            if let error = error {
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
    
    private func filterSelectedPeopleFromSearchResults(results:[SearchPerson]) {
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
    
    private func personSelected(person: Person) -> Bool {
        let filter = toPeople.filter() {$0.id == person.id}
        if filter.count > 0 {
            return true
        }
        return false
    }
    
    private func personEmailSelected(person: Person) -> String {
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
    
    private func formatNextLabel() {
        let numSlowposts = toPeople.count + toSearchPeople.count
        let numEmails = toEmails.count
        var title:String?
        
        var slowpostString:String!
        if numSlowposts > 1 {
            slowpostString = "\(numSlowposts) people on Slowpost"
        }
        else if numSlowposts > 0 {
            slowpostString = "\(numSlowposts) person on Slowpost"
        }
        
        if numSlowposts > 0 && numEmails > 0 {
            title = "Write to \(slowpostString) and \(numEmails) on email"
        }
        else if numSlowposts > 0 {
            title = "Write to \(slowpostString)"
        }
        else if numEmails > 1 {
            title = "Write to \(numEmails) people on email"
        }
        else if numEmails > 0 {
            title = "Write to \(numEmails) person on email"
        }
        else {
            title = ""
        }
        
        nextButton.setTitle(title, forState: .Normal)
        nextButton.titleLabel?.numberOfLines = 0
        nextButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
}
