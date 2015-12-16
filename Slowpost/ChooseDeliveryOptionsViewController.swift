//
//  ChooseDeliveryOptionsViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ChooseDeliveryOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var scheduledToArrive:NSDate?
    var deliveryMethod:String!
    @IBOutlet weak var optionsTable: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        formatCells()
        confirmButton.layer.cornerRadius = 5
        optionsTable.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMinimumDate() -> NSDate {
        return NSDate()
    }
    
    // Table configuration
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("express", forIndexPath: indexPath) as! ExpressDeliveryTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("standard", forIndexPath: indexPath) as! StandardDeliveryTableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("scheduled", forIndexPath: indexPath) as! ScheduleTableViewCell
            if scheduledToArrive != nil {
                cell.datePicker.date = scheduledToArrive!
            }
            else {
                cell.datePicker.date = setMinimumDate()
            }
            cell.datePicker.addTarget(self, action: "dateUpdated:", forControlEvents: UIControlEvents.ValueChanged)
            return cell
        }
    }
    
    func dateUpdated(sender: UIDatePicker) {
        deliveryMethod = "scheduled"
        scheduledToArrive = sender.date
        formatCells()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            return 270
        default:
            return 44
        }
    }
    
    func formatCells() {
        for index in 0...(optionsTable.numberOfRowsInSection(0)-1) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            let cell = optionsTable.cellForRowAtIndexPath(indexPath)!
            if cell.reuseIdentifier == deliveryMethod {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
        print("Row tapped")
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        deliveryMethod = cell.reuseIdentifier
        print("Selected \(deliveryMethod)")
        formatCells()
        optionsTable.reloadData()
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        performSegueWithIdentifier("deliveryOptionsCancelled", sender: nil)
    }    
    

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("deliveryOptionChosen", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "deliveryOptionChosen" {
            let destinationController = segue.destinationViewController as! ChooseImageAndComposeMailViewController
            destinationController.deliveryMethod = self.deliveryMethod
            if deliveryMethod == "scheduled" {
                destinationController.scheduledToArrive = self.scheduledToArrive
            }
            else {
                destinationController.scheduledToArrive = nil
            }
        }
    }
    

}
