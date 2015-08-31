//
//  SendingViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/5/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class SendingViewController: UIViewController {
    
    var image:UIImage!
    var username:String!
    var content:String!
    var scheduledToArrive:NSDate?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelButtonHeight: NSLayoutConstraint!
    
    var imageRequest: Alamofire.Request?
    var sendRequest: Alamofire.Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Began_Sending_Mail")
        
        cancelButton.layer.cornerRadius = 5
        
        sendMail()

        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        cancelButtonHeight.constant = 30
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMail() {
        
        FileService.uploadImage(image, filename: "image.jpg", completion: { (error, result) -> Void in
            if let imageUid = result as? String {
                self.sendMailToPostoffice(imageUid)
            }
            else {
                println("Unexpected result")
            }
        })
    }
    
    func sendMailToPostoffice(imageUid: String) {
        
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"
        var parameters:[String: String] = ["to": "\(username)", "content": "\(content)", "image_uid": "\(imageUid)"]
        
        if scheduledToArrive != nil {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            var scheduledToArriveString = dateFormatter.stringFromDate(scheduledToArrive!)
            println(scheduledToArriveString)
            parameters["scheduled_to_arrive"] = scheduledToArriveString
        }
        
        RestService.postRequest(sendMailEndpoint, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            if let response = result as? [AnyObject] {
                if response[0] as? Int == 201 {
                    Flurry.logEvent("Finished_Sending_Mail")
                    let nav = self.presentingViewController!
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        nav.dismissViewControllerAnimated(true, completion: {})
                    })
                }
            }
        })
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        var lastRequestEndpoint:String? = RestService.endpointForLastPostRequest()
        if lastRequestEndpoint != nil {
            if lastRequestEndpoint! == "send" || lastRequestEndpoint! == "upload" {
                lastPostRequest.cancel()
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
    }
    

}
