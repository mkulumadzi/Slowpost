//
//  SendingViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/5/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import CoreData

class SendingViewController: UIViewController {
    
    var image:UIImage!
    var username:String!
    var content:String!
    var scheduledToArrive:NSDate?
    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    var manuallyCancelled:Bool!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelButtonHeight: NSLayoutConstraint!
    
    var imageRequest: Alamofire.Request?
    var sendRequest: Alamofire.Request?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Began_Sending_Mail")
        manuallyCancelled = false
        
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
        
        let fileName = generateFileName()
        FileService.uploadImage(image, filename: fileName, completion: { (error, result) -> Void in
            if let imageUid = result as? String {
                FileService.saveImageToDirectory(self.image, fileName: fileName)
                self.sendMailToPostoffice(imageUid)
            }
            else {
                if self.manuallyCancelled == false {
                    self.performSegueWithIdentifier("mailFailedToSend", sender: nil)
                }
            }
        })
    }
    
    func generateFileName() -> String {
        let uuid = NSUUID().UUIDString
        let fileName = uuid + ".jpg"
        return fileName
    }
    
    func sendMailToPostoffice(imageUid: String) {
        
        let userId = LoginService.getUserIdFromToken()
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(userId)/mail/send"
        let correspondents = formatCorrespondents()
        var parameters:[String : AnyObject] = ["correspondents": correspondents, "attachments": ["notes": [content], "image_attachments": [imageUid]]]
        
        if scheduledToArrive != nil {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let scheduledToArriveString = dateFormatter.stringFromDate(scheduledToArrive!)
            print(scheduledToArriveString)
            parameters["scheduled_to_arrive"] = scheduledToArriveString
        }
        
        RestService.postRequest(sendMailEndpoint, parameters: parameters, headers: nil, completion: { (error, result) -> Void in
            if let response = result as? [AnyObject] {
                if response[0] as? Int == 201 {
                    MailService.updateAllData( {error, result -> Void in
                        if error != nil { print (error) }
                    })
                    Flurry.logEvent("Finished_Sending_Mail")
                    
                    let greatgrandparent = self.presentingViewController!.presentingViewController!.presentingViewController!
                    print(greatgrandparent)
                    if let _ = greatgrandparent as? UITabBarController {
                        greatgrandparent.dismissViewControllerAnimated(true, completion: {})
                    }
                    else {
                        let presenter = self.presentingViewController!
                        self.dismissViewControllerAnimated(true, completion: { Void in
                            presenter.dismissViewControllerAnimated(true, completion: {})
                        })
                    }
                }
            }
        })
        
    }
    
    func formatCorrespondents() -> [String : [String]] {
        var correspondents = [String : [String]]()
        if (toPeople.count > 0 || toSearchPeople.count > 0) && toEmails.count > 0 {
            correspondents = ["to_people": peopleIds(), "emails": toEmails]
        }
        else if toEmails.count > 0 {
            correspondents = ["emails": toEmails]
        }
        else {
            correspondents = ["to_people": peopleIds()]
        }
        return correspondents
    }
    
    func peopleIds() -> [String] {
        var peopleIds = [String]()
        for person in toPeople {
            peopleIds.append(person.id)
        }
        for searchPerson in toSearchPeople {
            peopleIds.append(searchPerson.id)
        }
        return peopleIds
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        manuallyCancelled = true
        let lastRequestEndpoint:String? = RestService.endpointForLastPostRequest()
        if lastRequestEndpoint != nil {
            if lastRequestEndpoint! == "send" || lastRequestEndpoint! == "upload" {
                lastPostRequest.cancel()
                self.performSegueWithIdentifier("notReadyToSend", sender: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mailFailedToSend" {
            
            let chooseDeliveryOptionsController = segue.destinationViewController as? ChooseDeliveryOptionsViewController
            chooseDeliveryOptionsController!.warningLabel.show("Mail failed to send.")
            
            // Delay the dismissal by 5 seconds
            let delay = 5.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                chooseDeliveryOptionsController!.warningLabel.hide()
            })
        }
    }
    

}
