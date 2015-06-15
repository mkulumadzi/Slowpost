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
var people = [Person]()

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
            
            var storyboard = UIStoryboard(name: "login", bundle: nil)
            var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        }
        else {
            
            //Initially populate mailbox by retrieving mail for the user
            DataManager.getMyMailbox( { (error, result) -> Void in
                if error != nil {
                    println(error)
                }
                else if let mailArray = result as? Array<Mail> {
                    mailbox = mailArray
                    //Get all peoplle records
                    DataManager.getPeople("", completion: { (error, result) -> Void in
                        if error != nil {
                            println(error)
                        }
                        else if let peopleArray = result as? Array<Person> {
                            people = peopleArray
                            self.goToHomeScreen()
                        }
                    })
                }
            })
            
            
        }
    }
    
    func goToHomeScreen() {
        var storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
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
