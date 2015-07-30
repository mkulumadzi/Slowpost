//
//  ComposeMailViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ComposeMailViewController: UIViewController, UITextViewDelegate {
    
    var imageName:String!
    var toPerson:Person!
    var keyboardShowing:Bool!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var composeText: UITextView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardShowing = false
        toLabel.text = toPerson.name
        
        composeText.textContainerInset.left = 10
        composeText.textContainerInset.right = 10

        addTopBorderToTextView(composeText)
        
        if let image = imageName {
            imagePreview.image = UIImage(named: image)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        resignFirstResponder()

        // Do any additional setup after loading the view.
    }
    
    func addTopBorderToTextView(textView: UITextView) {
        
        let border = CALayer()
        let thickness = CGFloat(1.0)
        border.borderColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: 0, width:  textView.frame.size.width, height: thickness)
        
        border.borderWidth = thickness
        textView.layer.addSublayer(border)
        textView.layer.masksToBounds = true
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
        
        //Upload Image to AWS
        let uploadURL = "\(PostOfficeURL)upload"
        let parameters = ["file": "foo", "filename": "testiOSUpload.png"]
        let image = imagePreview.image!
        
        FileService.uploadImage(image, filename: imageName, completion: { (error, result) -> Void in
            if let imageKey = result as? String {
                self.sendMailToPostoffice(imageKey)
            }
            else {
                println("Unexpected result")
            }
        })
    }
    
    func sendMailToPostoffice(imageKey: String) {
    
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"
        let parameters = ["to": "\(toPerson.username)", "content": "\(composeText.text)", "image": "\(imageKey)"]
        
        RestService.postRequest(sendMailEndpoint, parameters: parameters, completion: { (error, result) -> Void in
            if let response = result as? [AnyObject] {
                if response[0] as? Int == 201 {
                    var storyboard = UIStoryboard(name: "home", bundle: nil)
                    var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        })
        
    }
    
//    func uploadImageToAWS() {
//        let uploadURL = "\(PostOfficeURL)upload"
//        let parameters = ["file": "foo", "filename": "testiOSUpload.png"]
//        let image = imagePreview.image!
//        
//        FileService.uploadImage(image, filename: imageName, completion: { (error, result) -> Void in
//            if let response = result as? String {
//                println(response)
//            }
//        })
//    }
    
    func textViewDidChange(textView: UITextView) {
        doneButton.enabled = true
    }

}
