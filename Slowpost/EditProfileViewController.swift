//
//  EditProfileViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 6/15/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class EditProfileViewController: UITableViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet var profileTable: UITableView!
    
    var loggedInUser:Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Began_Editing_Profile")
        
        loggedInUser = getLoggedInUser()
        
        navBar.frame.size = CGSize(width: navBar.frame.width, height: 60)
        
        nameField.text = loggedInUser.name
        usernameLabel.text = loggedInUser.username
        emailLabel.text = loggedInUser.primaryEmail
        
        let footerView = UIView(frame: CGRectZero)
        profileTable.tableFooterView = footerView
        profileTable.tableFooterView?.hidden = true
        profileTable.backgroundColor = UIColor.whiteColor()
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func getLoggedInUser() -> Person {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dataController = appDelegate.dataController
        let userId = LoginService.getUserIdFromToken()
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let predicate = NSPredicate(format: "id == %@", userId)
        fetchRequest.predicate = predicate
        let person = dataController.executeFetchRequest(fetchRequest)![0] as! Person
        return person
    }

    @IBAction func saveEditedInfo(sender: AnyObject) {
        saveButton.enabled = false
        
        let updatePersonURL = "\(PostOfficeURL)/person/id/\(loggedInUser.id)"
        let parameters = ["name": "\(nameField.text!)"]
        
        RestService.postRequest(updatePersonURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            print(result)
            if error != nil {
                print(error)
            }
            else {
                MailService.updateAllData({(error, result) -> Void in})
                self.performSegueWithIdentifier("updateSucceeded", sender: nil)
            }
        })
    }

    
    @IBAction func editingChanged(sender: AnyObject) {
        saveButton.enabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "updateSucceeded" {
            Flurry.logEvent("Updated_Profile")
            
            let conversationListViewController = segue.destinationViewController as? ConversationListViewController
            conversationListViewController!.messageLabel.show("Profile updated")
            
            // Delay the dismissal by 5 seconds
            let delay = 5.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                conversationListViewController!.messageLabel.hide()
            })
        }
    }
}
