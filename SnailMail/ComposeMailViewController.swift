//
//  ComposeMailViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class ComposeMailViewController: UIViewController {
    
    var imageName:String!
    var toUsername:String!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var composeText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toLabel.text = toUsername
        
        if let image = imageName {
            imagePreview.image = UIImage(named: image)
        }
        
        resignFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backToCard(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        
        sendMailToPostoffice( { (error, result) -> Void in
            if result!.statusCode == 201 {
                self.performSegueWithIdentifier("sendMail", sender: nil)
            }
        })
        
    }
    
    func sendMailToPostoffice(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"
        let parameters = ["to": "\(toUsername)", "content": "\(composeText.text)", "image": "\(imageName)"]
        
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

}
