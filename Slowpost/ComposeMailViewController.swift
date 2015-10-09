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
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var composeText: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var composeTextToTopLayoutGuide: NSLayoutConstraint!
    @IBOutlet weak var composeTextToImageBottom: NSLayoutConstraint!
    
    @IBOutlet weak var placeholderTextLabel: UILabel!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Opened_Compose_View")
        
        keyboardShowing = false
        toLabel.text = toList()
        composeTextToImageBottom.priority = 999
        composeTextToTopLayoutGuide.priority = 251
        
        self.automaticallyAdjustsScrollViewInsets = false
        validatePlaceholderLabel()
        composeText.textContainerInset.left = 10
        composeText.textContainerInset.right = 10
        
        if cardImage != nil {
            imagePreview.image = cardImage
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeText.addTopBorder()
    }
    
    func validatePlaceholderLabel() {
        if composeText.text != "" || self.keyboardShowing == true {
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
        self.keyboardShowing = true
        self.placeholderTextLabel.hidden = true
        if deviceType == "iPhone 4S" {
            composeTextToTopLayoutGuide.constant = 114
        }
        else if deviceType == "iPhone 5" || deviceType == "iPhone 5C" || deviceType == "iPhone 5S" {
            composeTextToTopLayoutGuide.constant = 164
        }
        else if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
            composeTextToTopLayoutGuide.constant = 164
        }
        else {
            composeTextToTopLayoutGuide.constant = self.view.frame.width * 3/8 + 64
        }
        
        
        let userInfo = notification.userInfo!
        var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = self.composeText.convertRect(r, fromView:nil)
        self.composeText.contentInset.bottom = r.size.height
        self.composeText.scrollIndicatorInsets.bottom = r.size.height
    }
    
    func keyboardHide(notification:NSNotification) {
        self.keyboardShowing = false
        composeTextToImageBottom.priority = 999
        composeTextToTopLayoutGuide.priority = 251
        self.validatePlaceholderLabel()
        self.composeText.contentInset = UIEdgeInsetsZero
        self.composeText.scrollIndicatorInsets = UIEdgeInsetsZero
        self.updateViewConstraints()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("tapped")
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backToCard(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chooseDelivery" {
            let chooseDeliveryOptionsViewController = segue.destinationViewController as? ChooseDeliveryOptionsViewController
            chooseDeliveryOptionsViewController!.toPeople = toPeople
            chooseDeliveryOptionsViewController!.toSearchPeople = toSearchPeople
            chooseDeliveryOptionsViewController!.toEmails = toEmails
            chooseDeliveryOptionsViewController!.cardImage = cardImage
            chooseDeliveryOptionsViewController!.content = composeText.text
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        validatePlaceholderLabel()
        doneButton.enabled = true
    }

}
