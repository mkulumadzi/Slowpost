//
//  RequestPasswordResetViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 10/16/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RequestPasswordResetViewController: UIViewController {
    
    
    @IBOutlet weak var warningLabel: WarningUILabel!
    @IBOutlet weak var emailTextField: BottomBorderUITextField!
    @IBOutlet weak var submitButton: TextUIButton!

    @IBOutlet weak var submitButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var distanceToEmailField: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningLabel.hide()
        emailTextField.addBottomLayer()
        submitButton.layer.cornerRadius = 5
        validateSubmitButton()

        if deviceType == "iPhone 4S" {
            formatForiPhone4S()
        }
        
    }
    
    func formatForiPhone4S() {
        distanceToEmailField.constant = 50
        submitButtonHeight.constant = 30
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateSubmitButton() {
        if emailTextField.text != "" {
            submitButton.enable()
        }
        else {
            submitButton.disable()
        }
    }
    
    
    @IBAction func editingChanged(sender: AnyObject) {
        warningLabel.hide()
        validateSubmitButton()
    }
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        submitButton.disable()
        let resetPasswordURL = "\(PostOfficeURL)request_password_reset"
        let email = emailTextField.text!
        let parameters = ["email": email]
        let headers:[String: String] = ["Authorization": "Bearer \(appToken)", "Content-Type": "application/json"]
        
        Alamofire.request(.POST, resetPasswordURL, parameters: parameters, headers: headers, encoding: .JSON)
        .responseJSON { (response) in
            let status = response.response!.statusCode
            if status == 201 {
                self.performSegueWithIdentifier("requestSubmitted", sender: nil)
            }
            else {
                switch response.result {
                case .Success(let result):
                    let warning = JSON(result)
                    self.warningLabel.show(warning["message"].stringValue)
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }


}
