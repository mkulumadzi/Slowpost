//
//  ToViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class ToViewController: UIViewController {
    
    var contents:String!
    @IBOutlet weak var toSearchField: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
    
    @IBAction func sendMail(sender: AnyObject) {
        
        sendMailToPostoffice( { (error, result) -> Void in
            if result!.statusCode == 201 {
                self.performSegueWithIdentifier("mailSent", sender: nil)
            }
        })
        
    }
    
    func sendMailToPostoffice(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"
        let parameters = ["to": "\(toSearchField.text)", "content": "\(contents)"]
        
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
    
    @IBAction func backToCompose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as? MailCell
//        
//        let mail = mailbox[indexPath.row] as Mail
//        let fromPerson = getPerson(mail.from)
//        
//        cell?.mail = mail
//        cell?.from = fromPerson
//        cell?.fromLabel.text = "From: \(fromPerson.name)"
//        
//        return cell!
//        
//    }
//    
//    //I'm sure there is a better way to do this...
//    func getPerson(username: String) -> Person {
//        var person_to_get:Person!
//        for person in people {
//            if person.username == username {
//                person_to_get = person
//            }
//        }
//        return person_to_get
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "viewMail" {
//            let mailViewController = segue.destinationViewController as? MailViewController
//            if let mailCell = sender as? MailCell {
//                mailViewController?.mail = mailCell.mail
//                mailViewController?.from = mailCell.from
//                
//            }
//        }
//    }
//    
//    
//    @IBAction func Compose(sender: AnyObject) {
//        
//        var storyboard = UIStoryboard(name: "compose", bundle: nil)
//        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
//        
//        self.presentViewController(controller, animated: true, completion: nil)
//        
//        
//    }
    
}
