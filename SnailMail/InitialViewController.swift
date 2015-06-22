//
//  InitialViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

var loggedInUser:Person!
var mailbox = [Mail]()
var people = [Person]()

class InitialViewController: UIViewController {

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
                    mailbox = mailArray.sorted { $0.scheduledToArrive.compare($1.scheduledToArrive) == NSComparisonResult.OrderedDescending }
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

}
