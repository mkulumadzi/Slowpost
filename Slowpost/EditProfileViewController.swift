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
import SwiftyJSON

class EditProfileViewController: UITableViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet var profileTable: UITableView!
    var warningLabel:WarningUILabel!
    
    @IBOutlet weak var givenNameField: UITextField!
    @IBOutlet weak var familyNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var logOutButton: TextUIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    @IBOutlet weak var spaceToFacebookButton: NSLayoutConstraint!
    
    var loggedInUser:Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateLoginButtons()
        
        saveButton.enabled = false
        
        Flurry.logEvent("Began_Editing_Profile")
        
        loggedInUser = getLoggedInUser()
        addWarningLabel()
        warningLabel.hide()
        
        navBar.frame.size = CGSize(width: navBar.frame.width, height: 60)
        
        logOutButton.layer.cornerRadius = 5
        facebookLoginButton.layer.cornerRadius = 5
        
        givenNameField.text = loggedInUser.givenName
        familyNameField.text = loggedInUser.familyName
        usernameLabel.text = loggedInUser.username
        emailField.text = loggedInUser.primaryEmail
        
        let footerView = UIView(frame: CGRectZero)
        profileTable.tableFooterView = footerView
        profileTable.tableFooterView?.hidden = true
        profileTable.backgroundColor = UIColor.whiteColor()
        
        facebookLoginButton.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        validateLoginButtons()
    }
    
    func addWarningLabel() {
        let frame = CGRect(x: 0.0, y: 60.0, width: view.frame.width, height: 30.0)
        warningLabel = WarningUILabel(frame: frame)
        warningLabel.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1.0)
        warningLabel.font = UIFont(name: "OpenSans", size: 15.0)
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.text = "Consider yourself warned"
        warningLabel.textAlignment = .Center
        view.addSubview(warningLabel)
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
        let parameters = ["given_name": "\(givenNameField.text!)", "family_name": "\(familyNameField.text!)", "email": "\(emailField.text!)"]
        
        RestService.postRequest(updatePersonURL, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else if let _ = result as? [AnyObject] {
                MailService.updateAllData({(error, result) -> Void in})
                self.performSegueWithIdentifier("updateSucceeded", sender: nil)
            }
            else {
                let json = JSON(result!)
                let message = json["message"].stringValue
                self.warningLabel.show(message)
            }
        })
    }

    
    @IBAction func editingChanged(sender: AnyObject) {
        warningLabel.hide()
        saveButton.enabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func validateLoginButtons() {
        facebookLoginButton.hidden = false
        if FBSDKAccessToken.currentAccessToken() != nil {
            logOutButton.hidden = true
            spaceToFacebookButton.constant = 10
        }
        else {
            logOutButton.hidden = false
            spaceToFacebookButton.constant = 60
        }
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        logOutButton.hidden = true
        facebookLoginButton.hidden = true
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            print(error)
        }
        else {
            LoginService.updateUserFacebookId()
            validateLoginButtons()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        FBSDKAccessToken.setCurrentAccessToken(nil)
        self.performSegueWithIdentifier("loggedOut", sender: nil)
    }
    
    
    @IBAction func logOutButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("loggedOut", sender: nil)
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
