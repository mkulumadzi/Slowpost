//
//  SentMailDetailViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 7/27/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class SentMailDetailViewController: UIViewController {

    var toPerson:Person!
    var mail:Mail!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var mailContent: UILabel!
    @IBOutlet weak var mailImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailContent.text = mail.content
        mailImage.image = getImage()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //To Do: Abstract this function into a separate class.
    func getImage() -> UIImage {
        if mail.image != nil {
            if let image = UIImage(named: mail.image) {
                return image
            }
        }
        return UIImage(named: "Default Card.png")!
    }
    
    @IBAction func closeView(sender: AnyObject) {
        
        //Connecting this button to the unwind segue on Profile View wasn't working, so dismissing view manually
        self.dismissViewControllerAnimated(true, completion: {})
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
