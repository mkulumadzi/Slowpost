//
//  ToViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire


class ToViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var contents:String!
    var imageName:String!
    var toUsername:String!
    var toList: [Person] = []
    
    @IBOutlet weak var toSearchField: UISearchBar!
    @IBOutlet weak var toPersonList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toList = people
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendMail(sender: AnyObject) {
        
        sendMailToPostoffice( { (error, result) -> Void in
            if result!.statusCode == 201 {
                self.performSegueWithIdentifier("mailSent", sender: nil)
            }
        })
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        toList = people
        
        if self.toSearchField.text.isEmpty == false {
            var newArray:[Person] = toList.filter() {
                self.listMatches(self.toSearchField.text, inString: $0.username).count >= 1 || self.listMatches(self.toSearchField.text, inString: $0.name).count >= 1
            }
            toList = newArray
        }
        
        self.toPersonList.reloadData()
    }
    
    func listMatches(pattern: String, inString string: String) -> [String] {
        let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: nil)
        let range = NSMakeRange(0, count(string))
        let matches = regex?.matchesInString(string, options: .allZeros, range: range) as! [NSTextCheckingResult]
        
        return matches.map {
            let range = $0.range
            return (string as NSString).substringWithRange(range)
        }
    }
    
    func sendMailToPostoffice(completion: (error: NSError?, result: AnyObject?) -> Void) {
        
        let sendMailEndpoint = "\(PostOfficeURL)person/id/\(loggedInUser.id)/mail/send"
        let parameters = ["to": "\(toUsername)", "content": "\(contents)", "image": "\(imageName)"]
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personCell", forIndexPath: indexPath) as? PersonCell
        
        let person = toList[indexPath.row] as Person
        cell?.personNameLabel.text = person.name
        cell?.usernameLabel.text = person.username
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let person = toList[indexPath.row] as Person
        
        toUsername = person.username
        
    }
    
}
