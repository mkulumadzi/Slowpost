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
    var cardImage:UIImage!
    var keyboardShowing:Bool!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var composeText: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var placeholderTextLabel: UILabel!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Opened_Compose_View")
        
        keyboardShowing = false
        toLabel.text = toPeopleNames()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        validatePlaceholderLabel()
        composeText.textContainerInset.left = 10
        composeText.textContainerInset.right = 10

        composeText.addTopBorder()
        
        if cardImage != nil {
            imagePreview.image = cardImage
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        resignFirstResponder()
    }
    
    func validatePlaceholderLabel() {
        if composeText.text != "" || self.keyboardShowing == true {
            placeholderTextLabel.hidden = true
        }
        else {
            placeholderTextLabel.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toPeopleNames() -> String {
        var names = ""
        var index = 0
        for person in toPeople {
            if index > 0 { names += ", " }
            names += person.name
            index += 1
        }
        return names
    }
    
    func keyboardShow(notification: NSNotification) {
        self.keyboardShowing = true
        self.placeholderTextLabel.hidden = true
        
        let userInfo = notification.userInfo!
        var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = self.composeText.convertRect(r, fromView:nil)
        self.composeText.contentInset.bottom = r.size.height
        self.composeText.scrollIndicatorInsets.bottom = r.size.height
    }
    
    func keyboardHide(notification:NSNotification) {
        self.keyboardShowing = false
        self.validatePlaceholderLabel()
        self.composeText.contentInset = UIEdgeInsetsZero
        self.composeText.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
            chooseDeliveryOptionsViewController!.cardImage = cardImage
            chooseDeliveryOptionsViewController!.content = composeText.text
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        validatePlaceholderLabel()
        doneButton.enabled = true
    }

}
