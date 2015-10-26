//
//  ComposeMailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ComposeMailViewController: UIViewController, UITextViewDelegate {
    
    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    var cardImage:UIImage!
    var keyboardShowing:Bool!
    var scheduledToArrive:NSDate?
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var composeText: UITextView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    
    @IBOutlet weak var composeTextToTopLayoutGuide: NSLayoutConstraint!
    @IBOutlet weak var composeTextToImageBottom: NSLayoutConstraint!
    
    @IBOutlet weak var placeholderTextLabel: UILabel!
    
    @IBOutlet weak var bottomSpaceToSendButton: NSLayoutConstraint!
    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scheduleButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var scheduleButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaceToScheduleButton: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Opened_Compose_View")
        warningLabel.hide()
        
        keyboardShowing = false
        toLabel.text = toList()
        composeTextToImageBottom.priority = 999
        composeTextToTopLayoutGuide.priority = 251
        
        automaticallyAdjustsScrollViewInsets = false
        validatePlaceholderLabel()
        composeText.textContainerInset.left = 10
        composeText.textContainerInset.right = 10
        
        if cardImage != nil {
            imagePreview.image = cardImage
        }
        
        if deviceType == "iPhone 4S" {
            formatForiPhone4()
        }
        
        formatButtons()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        resignFirstResponder()
    }
    
    func formatForiPhone4() {
        sendButtonHeight.constant = 30
        scheduleButtonHeight.constant = 30
        scheduleButtonWidth.constant = 30
    }
    
    func formatButtons() {
        scheduleButton.setImage(UIImage(named: "calendar")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        scheduleButton.tintColor = UIColor.whiteColor()
        
        sendButton.contentHorizontalAlignment = .Right
        sendButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeText.addTopBorder()
    }
    
    func validatePlaceholderLabel() {
        if composeText.text != "" || keyboardShowing == true {
            placeholderTextLabel.hidden = true
            print("hiding placeholder")
        }
        else {
            placeholderTextLabel.hidden = false
            print("showing placeholder")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toList() -> String {
        var toList = ""
        var index = 0
        for person in toPeople {
            if index > 0 { toList += ", " }
            toList += person.fullName()
            index += 1
        }
        for searchPerson in toSearchPeople {
            if index > 0 { toList += ", " }
            toList += searchPerson.fullName()
            index += 1
        }
        for email in toEmails {
            if index > 0 { toList += ", " }
            toList += email
            index += 1
        }
        return toList
    }
    
    func keyboardShow(notification: NSNotification) {
        composeTextToImageBottom.priority = 251
        composeTextToTopLayoutGuide.priority = 999
        keyboardShowing = true
        placeholderTextLabel.hidden = true
        if deviceType == "iPhone 4S" {
            composeTextToTopLayoutGuide.constant = 64
        }
        else if deviceType == "iPhone 5" || deviceType == "iPhone 5C" || deviceType == "iPhone 5S" {
            composeTextToTopLayoutGuide.constant = 114
        }
        else if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
            composeTextToTopLayoutGuide.constant = 164
        }
        else {
            composeTextToTopLayoutGuide.constant = view.frame.width * 3/8 + 64
        }
        
        let userInfo = notification.userInfo!
        var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = composeText.convertRect(r, fromView:nil)
        composeText.contentInset.bottom = r.size.height + sendButtonHeight.constant
        composeText.scrollIndicatorInsets.bottom = r.size.height + sendButtonHeight.constant
        bottomSpaceToSendButton.constant = r.size.height
        bottomSpaceToScheduleButton.constant = r.size.height
    }
    
    func keyboardHide(notification:NSNotification) {
        keyboardShowing = false
        composeTextToImageBottom.priority = 999
        composeTextToTopLayoutGuide.priority = 251
        validatePlaceholderLabel()
        composeText.contentInset = UIEdgeInsetsZero
        composeText.scrollIndicatorInsets = UIEdgeInsetsZero
        bottomSpaceToSendButton.constant = 0
        bottomSpaceToScheduleButton.constant = 0
        updateViewConstraints()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("tapped")
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backToCard(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sendMail" {
            let sendingViewController = segue.destinationViewController as? SendingViewController
            sendingViewController!.toPeople = toPeople
            sendingViewController!.toSearchPeople = toSearchPeople
            sendingViewController!.toEmails = toEmails
            sendingViewController!.image = cardImage
            sendingViewController!.content = composeText.text
            
            if scheduledToArrive != nil {
                sendingViewController!.scheduledToArrive = scheduledToArrive!
            }
        }
    }
    
    @IBAction func mailFailedToSend(segue: UIStoryboardSegue) {
    }
    
    @IBAction func notReadyToSend(segue: UIStoryboardSegue) {
    }
    
    @IBAction func standardDeliveryChosen(segue: UIStoryboardSegue) {
        formatSendButton()
    }
    
    @IBAction func scheduledDeliveryChosen(segue: UIStoryboardSegue) {
        formatSendButton()
    }
    
    func formatSendButton() {
        if scheduledToArrive != nil {
            let dateString = scheduledToArrive!.formattedAsString("yyyy-MM-dd")
            sendButton.setTitle("Send (arrives on \(dateString)) >>", forState: .Normal)
        }
        else {
            sendButton.setTitle("Send (arrives in 1 to 2 days)  >>", forState: .Normal)
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        validatePlaceholderLabel()
    }

}
