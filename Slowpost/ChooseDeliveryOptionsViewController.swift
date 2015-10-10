//
//  ChooseDeliveryOptionsViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ChooseDeliveryOptionsViewController: UIViewController {
    
    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    var cardImage:UIImage!
    var content:String!
    var scheduledToArrive:NSDate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var standardButton: TextUIButton!
//    @IBOutlet weak var expressButton: TextUIButton!
    @IBOutlet weak var customButton: TextUIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var standardDeliveryButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var distanceToScheduledSection: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.hide()
        
        standardButton.layer.cornerRadius = 5
//        expressButton.layer.cornerRadius = 5
        customButton.layer.cornerRadius = 5
        datePicker.minimumDate = setMinimumDate()

        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        standardDeliveryButtonHeight.constant = 30
        buttonHeight.constant = 30
        distanceToScheduledSection.constant = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMinimumDate() -> NSDate {
        let userCalendar = NSCalendar.currentCalendar()
        let minimumDate = userCalendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: .MatchFirst)
        return minimumDate!
    }
    
    @IBAction func standardDeliveryChosen(sender: AnyObject) {
        self.performSegueWithIdentifier("sendMail", sender: nil)
    }
    
//    @IBAction func expressDeliveryChosen(sender: AnyObject) {
//        let calendar = NSCalendar.currentCalendar()
//        let date = calendar.dateByAddingUnit(.Minute, value: 10, toDate: NSDate(), options: [])
//        scheduledToArrive = date!
//        self.performSegueWithIdentifier("sendMail", sender: nil)
//    }
    
    @IBAction func customDeliveryChosen(sender: AnyObject) {
        let currentDateTime = NSDate()
        if datePicker.date.isGreaterThanDate(currentDateTime) {
            scheduledToArrive = datePicker.date
            self.performSegueWithIdentifier("sendMail", sender: nil)
        }
        else {
            print("Date cannot be in the past")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sendMail" {
            let sendingViewController = segue.destinationViewController as? SendingViewController
            sendingViewController!.toPeople = toPeople
            sendingViewController!.toSearchPeople = toSearchPeople
            sendingViewController!.toEmails = toEmails
            sendingViewController!.image = cardImage
            sendingViewController!.content = content
            
            if scheduledToArrive != nil {
                sendingViewController!.scheduledToArrive = scheduledToArrive!
            }
        }
        
    }
    
    @IBAction func mailFailedToSend(segue: UIStoryboardSegue) {
        
    }
    
    

}
