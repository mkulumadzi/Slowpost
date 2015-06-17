//
//  ViewProfileViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/15/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ViewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var outbox = [Mail]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sentMailTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getOutbox()
        
        nameLabel.text = loggedInUser.name

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func Mailbox(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "mailbox", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: false, completion: nil)
    }
    
    
    @IBAction func Compose(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "compose", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func logOut(sender: AnyObject) {
        loggedInUser = nil
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialController") as! UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func getOutbox() {
        DataManager.getMyOutbox( { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                self.outbox = mailArray
                self.sentMailTable.reloadData()
            }
        })
    }
    
    func configureTableView() {
        println("configuring!")
        sentMailTable.rowHeight = UITableViewAutomaticDimension
        sentMailTable.estimatedRowHeight = 386
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outbox.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MailCell", forIndexPath: indexPath) as? SentMailTableViewCell
        
        let mail = outbox[indexPath.row] as Mail
        let toPerson = getPerson(mail.to)
        
        cell?.mail = mail
        cell?.person = toPerson
        cell?.cardImage.image = getImage(mail)
        
        return cell!
        
    }
    
    //I'm sure there is a better way to do this...
    func getPerson(username: String) -> Person {
        var person_to_get:Person!
        for person in people {
            if person.username == username {
                person_to_get = person
            }
        }
        return person_to_get
    }
    
    func getImage(mail: Mail) -> UIImage {
        if mail.image != nil {
            if let image = UIImage(named: mail.image) {
                return image
            }
        }
        return UIImage(named: "Default Card.png")!
    }
    

}
