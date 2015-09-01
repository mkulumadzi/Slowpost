//
//  PhoneEntryViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/13/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class PhoneEntryViewController: UIViewController {
    
    
    @IBOutlet weak var phoneTextField: BottomBorderUITextField!
    @IBOutlet weak var signUpButton: TextUIButton!
    @IBOutlet weak var warningLabel: WarningUILabel!
    
    var name:String!
    var email:String!
    var username:String!
    var password:String!


    @IBOutlet weak var verticalSpaceToTitle: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceToPhone: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Phone_View_Opened")
        
        phoneTextField.addBottomLayer()
        signUpButton.layer.cornerRadius = 5
        warningLabel.hide()

        if deviceType == "iPhone 4S" {
            self.formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        
        verticalSpaceToTitle.constant = 10
        verticalSpaceToPhone.constant = 10
        buttonHeight.constant = 30
        
        phoneTextField.font = phoneTextField.font.fontWithSize(15.0)
        
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
        signUpButton.enable()
        warningLabel.hide()
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        signUpButton.disable()
        
        if phoneTextField.text == "" {
            self.signUp()
        }
        else {
            let params = ["phone": phoneTextField.text!]
            
            LoginService.checkFieldAvailability(params, completion: { (error, result) -> Void in
                if error != nil {
                    println(error)
                }
                else if let availability = result!.valueForKey("phone") as? String {
                    if availability == "available" {
                        self.signUp()
                    }
                    else {
                        self.warningLabel.show("An account with that phone number already exists.")
                    }
                }
                else {
                    println("Unexpected result when checking field availability")
                }
            })
        }
    }
    
    func signUp() {
        
        let newPersonURL = "\(PostOfficeURL)person/new"
        var parameters = ["name": "\(name)", "username": "\(username)", "email": "\(email)", "phone": "\(phoneTextField.text)", "password": "\(password)"]
        
        let headers:[String: String] = ["Authorization": "Bearer \(appToken)"]
        
        RestService.postRequest(newPersonURL, parameters: parameters, headers: headers, completion: { (error, result) -> Void in
            if let response = result as? [AnyObject] {
                if response[0] as? Int == 201 {
                    if let location = response[1] as? String {
                        
                        let parameters = ["username": "\(self.username)", "password": "\(self.password)"]
                        
                        LoginService.logIn(parameters, completion: { (error, result) -> Void in
                            if error != nil {
                                println(error)
                            }
                            else if result as? String == "Success" {
                                self.performSegueWithIdentifier("signUpComplete", sender: nil)
                            }
                        })
                    }
                }
                else if let error_message = response[1] as? String {
                    self.warningLabel.show(error_message)
                }
            }
        })
    }

}
