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
    
    
    @IBOutlet weak var composeText: UITextView!
    @IBOutlet weak var toField: UITextField!
    
    var mail:Mail!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func sendMail(sender: AnyObject) {
        
        sendMailToPostoffice( { (error, result) -> Void in
            if result!.statusCode == 201 {
                self.performSegueWithIdentifier("mailSent", sender: nil)
            }
        })
        
    }
    
    func sendMailToPostoffice(completion: (error: NSError?, result: AnyObject?) -> Void) {
    
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"
        let parameters = ["to": "\(toField.text)", "content": "\(composeText.text)"]
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
