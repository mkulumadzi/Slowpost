//
//  ComposeMailViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class ComposeMailViewController: UIViewController, UITextViewDelegate {
    
    var imageName:String!
    var toPerson:Person!
    var keyboardShowing:Bool!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var composeText: UITextView!
    @IBOutlet weak var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardShowing = false
        toLabel.text = toPerson.name
        
        composeText.textContainerInset.left = 10
        composeText.textContainerInset.right = 10
        
        if let image = imageName {
            imagePreview.image = UIImage(named: image)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        resignFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardShow(notification: NSNotification) {
        self.keyboardShowing = true
        
        let userInfo = notification.userInfo!
        var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = self.composeText.convertRect(r, fromView:nil)
        self.composeText.contentInset.bottom = r.size.height
        self.composeText.scrollIndicatorInsets.bottom = r.size.height
    }
    
    func keyboardHide(notification:NSNotification) {
        self.keyboardShowing = false
        self.composeText.contentInset = UIEdgeInsetsZero
        self.composeText.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backToCard(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        doneButton.enabled = false

        sendMailToPostoffice( { (error, result) -> Void in
            if result!.statusCode == 201 {
                self.performSegueWithIdentifier("sendMail", sender: nil)
            }
        })
        
    }
    
    func sendMailToPostoffice(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"
        let parameters = ["to": "\(toPerson.username)", "content": "\(composeText.text)", "image": "\(imageName)"]
        
        Alamofire.request(.POST, sendMailEndpoint, parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in
                if let anError = error {
                    println(error)
                    completion(error: error, result: nil)
                }
                else if let response: AnyObject = response {
                    completion(error: nil, result: response)
                }
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        doneButton.enabled = true
    }

}
