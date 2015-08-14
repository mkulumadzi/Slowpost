//
//  PersonalDetailsViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class PersonalDetailsViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: BottomBorderUITextField!
    @IBOutlet weak var emailTextField: BottomBorderUITextField!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        nameTextField.addBottomLayer()
        emailTextField.addBottomLayer()
        
        warningLabel.hide()
        
        validateNextButton()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        validateNextButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        validateNextButton()
        warningLabel.hide()
    }
    
    func validateNextButton() {
        if nameTextField.text != "" && emailTextField.text != "" {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func checkEmailAvailability(sender: AnyObject) {
        nextButton.enabled = false
        let params = ["email": emailTextField.text!]
        
        PersonService.checkFieldAvailability(params, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let availability = result!.valueForKey("email") as? String {
                if availability == "available" {
                    self.performSegueWithIdentifier("enterUsername", sender: nil)
                }
                else {
                    self.warningLabel.show("An account with that email already exists.")
                }
            }
            else {
                println("Unexpected result when checking field availability")
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enterUsername" {
            let destinationViewController = segue.destinationViewController as? UsernameViewController
            destinationViewController!.name = nameTextField.text
            destinationViewController!.email = emailTextField.text
        }
    }
    
}