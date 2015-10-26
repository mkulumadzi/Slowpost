//
//  ChooseDeliveryOptionsViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ChooseDeliveryOptionsViewController: UIViewController {
    
    
    var scheduledToArrive:NSDate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var standardButton: TextUIButton!
    @IBOutlet weak var standardButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = setMinimumDate()

        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        standardButtonHeight.constant = 30
        headerHeight.constant = 30
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scheduledDeliveryChosen" {
            let composeMailViewController = segue.destinationViewController as! ComposeMailViewController
            composeMailViewController.scheduledToArrive = datePicker.date
        }
        else if segue.identifier == "standardDeliveryChosen" {
            let composeMailViewController = segue.destinationViewController as! ComposeMailViewController
            composeMailViewController.scheduledToArrive = nil
        }
        
    }
    

}
