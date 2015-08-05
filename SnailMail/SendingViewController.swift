//
//  SendingViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 8/5/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SendingViewController: UIViewController {
    
    var image:UIImage!
    var username:String!
    var content:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendMail()

        // Do any additional setup after loading the view.
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
        let parameters = ["to": "\(username)", "content": "\(content)", "image_uid": "\(imageUid)"]
        
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

}
