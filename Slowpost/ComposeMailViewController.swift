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
    
    var shadedView:UIView!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var composeText: UITextView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var sendArrowsButton: UIButton!
    @IBOutlet weak var doneEditingButton: UIButton!
    
    @IBOutlet weak var composeTextToTopLayoutGuide: NSLayoutConstraint!
    @IBOutlet weak var composeTextToImageBottom: NSLayoutConstraint!
    @IBOutlet weak var doneButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var placeholderTextLabel: UILabel!
    
    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var scheduleButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var scheduleButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var sendArrowsHeigh: NSLayoutConstraint!
    
    @IBOutlet weak var bottomSpaceToDoneButton: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Opened_Compose_View")
        warningLabel.hide()
        
        doneEditingButton.hidden = true
        keyboardShowing = false
        toLabel.text = toList()
        composeTextToImageBottom.priority = 999
        composeTextToTopLayoutGuide.priority = 251
        
        initializeShadedView()
        
        automaticallyAdjustsScrollViewInsets = false
        validatePlaceholderLabel()
        validateSendButtons()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        resignFirstResponder()
    }
    
    func formatForiPhone4() {
        doneButtonHeight.constant = 30  
    }
    
    func formatButtons() {
        scheduleButton.setImage(UIImage(named: "calendar")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        scheduleButton.tintColor = slowpostBlack
        sendButton.contentHorizontalAlignment = .Right
        sendButton.titleLabel?.numberOfLines = 0
    }
    
    func initializeShadedView() {
        shadedView = UIView(frame: view.frame)
        shadedView.backgroundColor = slowpostBlack
        shadedView.alpha = 0.5
        view.addSubview(shadedView)
        shadedView.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeText.addTopBorder()
    }
    
    func validatePlaceholderLabel() {
        if composeText.text != "" || keyboardShowing == true {
            placeholderTextLabel.hidden = true
        }
        else {
            placeholderTextLabel.hidden = false
        }
    }
    
    func validateSendButtons() {
        if composeText.text == "" || keyboardShowing == true {
            scheduleButton.hidden = true
            sendButton.hidden = true
            sendArrowsButton.hidden = true
        }
        else {
            scheduleButton.hidden = false
            sendButton.hidden = false
            sendArrowsButton.hidden = false
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
        composeText.contentInset.bottom = r.size.height + doneButtonHeight.constant
        composeText.scrollIndicatorInsets.bottom = r.size.height + doneButtonHeight.constant
        validateSendButtons()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = composeText.convertRect(r, fromView:nil)
        doneEditingButton.hidden = false
        bottomSpaceToDoneButton.constant = r.size.height
    }
    
    func keyboardHide(notification:NSNotification) {
        keyboardShowing = false
        composeTextToImageBottom.priority = 999
        composeTextToTopLayoutGuide.priority = 251
        validatePlaceholderLabel()
        validateSendButtons()
        composeText.contentInset.bottom = 60
        composeText.scrollIndicatorInsets.bottom = 60
        doneEditingButton.hidden = true
        bottomSpaceToDoneButton.constant = 0
        updateViewConstraints()
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backToCard(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func sendTapped(sender: AnyObject) {
        performSegueWithIdentifier("sendMail", sender: nil)
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
        else if segue.identifier == "scheduleDelivery" {
            shadedView.hidden = false
        }
    }
    
    @IBAction func mailFailedToSend(segue: UIStoryboardSegue) {
    }
    
    @IBAction func notReadyToSend(segue: UIStoryboardSegue) {
    }
    
    @IBAction func standardDeliveryChosen(segue: UIStoryboardSegue) {
        shadedView.hidden = true
        formatSendButton()
    }
    
    @IBAction func scheduledDeliveryChosen(segue: UIStoryboardSegue) {
        shadedView.hidden = true
        formatSendButton()
    }
    
    @IBAction func scheduleDeliveryCancelled(segue: UIStoryboardSegue) {
        shadedView.hidden = true
    }
    
    func formatSendButton() {
        if scheduledToArrive != nil {
            let dateString = scheduledToArrive!.formattedAsString("yyyy-MM-dd")
            sendButton.setTitle("Send (arrives on \(dateString))", forState: .Normal)
        }
        else {
            sendButton.setTitle("Send (arrives in 1 to 2 days)", forState: .Normal)
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        validatePlaceholderLabel()
        validateSendButtons()
    }

}
