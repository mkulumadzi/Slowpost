//
//  WelcomeScreenViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

var loggedInUser:Person!
var mailbox = [Mail]()

class WelcomeScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLogin() {
        if loggedInUser == nil {
            performSegueWithIdentifier("LogIn", sender: self)
        }
        else {
                
            DataManager.getMyMailboxWithSuccess{ (mailData) -> Void in
                let json = JSON(data: mailData)
                
                for mailDict in json.arrayValue {
                    var id: String = mailDict["_id"]["$oid"].stringValue
                    var from: String = mailDict["from"].stringValue
                    var to: String = mailDict["to"].stringValue
                    var content: String = mailDict["content"].stringValue
                    
                    var mail = Mail(id: id, from: from, to: to, content: content)
                    
                    mailbox.append(mail)
                }
                
            }
            
            performSegueWithIdentifier("GoToHomeScreen", sender: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        checkLogin()
        
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
