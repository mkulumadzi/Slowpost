//
//  ViewProfileViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/15/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
//import CoreData

class ViewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var outbox = [Mail]()
    
    @IBOutlet weak var sentMailTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getOutbox()
        
        navBarTitle.title = loggedInUser.name

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        sentMailTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getOutbox() {
        DataManager.getMyOutbox( { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let mailArray = result as? Array<Mail> {
                self.outbox = mailArray.sorted { $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending }
                self.sentMailTable.reloadData()
                self.configureTableView()
            }
        })
    }
    
    func configureTableView() {
        sentMailTable.rowHeight = UITableViewAutomaticDimension
        sentMailTable.estimatedRowHeight = 370
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
        
        if let person = find(penpals.map({ $0.username }), mail.to) {
            cell?.person = penpals[person]
        }
        
        cell?.mail = mail
        cell?.cardImage.image = getImage(mail)
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func getImage(mail: Mail) -> UIImage {
        if mail.image != nil {
            if let image = UIImage(named: mail.image) {
                return image
            }
        }
        return UIImage(named: "Default Card.png")!
    }
    
    @IBAction func showSettingsMenu(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettingsMenu", sender: nil)
    }
    
    @IBAction func cancelFromSettingsMenuToProfileViewController(segue:UIStoryboardSegue) {
    }

}
