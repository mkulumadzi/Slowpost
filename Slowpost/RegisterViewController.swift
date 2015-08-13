//
//  RegisterViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 3/20/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: BottomBorderUITextField!
    @IBOutlet weak var usernameTextField: BottomBorderUITextField!
    @IBOutlet weak var emailTextField: BottomBorderUITextField!
    @IBOutlet weak var passwordTextField: BottomBorderUITextField!
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Quicksand-Regular", size: 24)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        nameTextField.addBottomLayer()
        usernameTextField.addBottomLayer()
        emailTextField.addBottomLayer()
        passwordTextField.addBottomLayer()
        
        warningLabel.hide()
        
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
        if nameTextField.text != "" && usernameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enterPhone" {
            let destinationViewController = segue.destinationViewController as? PhoneEntryViewController
            destinationViewController!.name = nameTextField.text
            destinationViewController!.username = usernameTextField.text
            destinationViewController!.email = emailTextField.text
            destinationViewController!.password = passwordTextField.text
        }
    }
    
}