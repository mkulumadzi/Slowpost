//
//  SettingsMenuViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData

class SettingsMenuViewController: UIViewController {
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var editPasswordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOutButton.layer.cornerRadius = 5
        editProfileButton.layer.cornerRadius = 5
        editPasswordButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logOut(sender: AnyObject) {
        deleteCoreDataObjects("Session")
        deleteCoreDataObjects("Mail")
        deleteCoreDataObjects("Person")
        
        loggedInUser = nil
        
        var storyboard = UIStoryboard(name: "initial", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func deleteCoreDataObjects(entityName: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        for object:NSManagedObject in fetchedResults! {
            managedContext.deleteObject(object)
        }
        
    }

}
