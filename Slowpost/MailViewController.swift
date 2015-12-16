//
//  MailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 9/3/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

//
//  ConversationMailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 8/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class MailViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var backgroundView:UIView!
    var cardView:UIView!
    var mailImage:UIImage!
    var mailImageView:UIImageView!
    var cardBack:UIView!
    var displayingFront:Bool!
    var fromView: UIView!
    var fromViewInitials: UILabel!
    var fromLabel: UILabel!
    var dateLabel: UILabel!
    var cardTextBorder: UIView!
    var toLabel: UILabel!
    var contents: UILabel!
    
    var replyButton: UIButton!
    var navItem: UINavigationItem!
    var closeButton: UIButton!
    var flipButton: UIButton!
    
    var imageHeight: NSLayoutConstraint!
    
    var managedContext:NSManagedObjectContext!
    var mail:Mail!
    var fromPerson:Person!

    var runOnClose: (() -> ())?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        Flurry.logEvent("Mail_Opened")
        
//        formatButtons()
        fromPerson = mail.fromPerson
        addImage()
        setupView()
        readMailIfNecessary()
        
//        let userId = LoginService.getUserIdFromToken()
//        if fromPerson.id == userId {
//            navItem.rightBarButtonItem = nil
//        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
//    func rotated() {
//        view.layoutIfNeeded()
//        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
//            print("landscape")
//            
//        }
//        else if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
//            print("Portrait")
//        }
//    }
    
    
//    func formatButtons() {
//        replyButton.setImage(UIImage(named: "reply")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
//        replyButton.tintColor = slowpostDarkGrey
//        
//        closeButton.setImage(UIImage(named: "close")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
//        closeButton.tintColor = slowpostDarkGrey
//    }
    
    func addImage() {
        mail.getImage({error, result -> Void in
            if let image = result as? UIImage {
                self.mailImage = image
            }
        })
    }
    
    func setupView() {
        addBackground()
        addCardView()
        addImageView()
        createCardBack()
        addTapGesture()
        addSwipeRightGesture()
        displayingFront = true
    }
    
    func addBackground() {
        view.backgroundColor = UIColor.clearColor()
        backgroundView = UIView(frame: view.frame)
        backgroundView.backgroundColor = slowpostBlack
        backgroundView.alpha = 0.8
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("closeMailView"))
        singleTap.numberOfTapsRequired = 1
        backgroundView.addGestureRecognizer(singleTap)
        
        view.addSubview(backgroundView)
    }
    
    func addCardView() {
        let rect = cardViewRect()
        cardView = UIView(frame: rect)
        view.addSubview(cardView)
    }
    
    func addTapGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        singleTap.numberOfTapsRequired = 1
        cardView.addGestureRecognizer(singleTap)
    }
    
    func addSwipeRightGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "closeMailView")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        cardView.addGestureRecognizer(swipeRight)
    }
    
    func cardViewRect() -> CGRect {
        let width = view.frame.width
        let height = view.frame.width * mailImage.size.height / mailImage.size.width
        let y = (view.frame.height - height) / 2.0
        let rect = CGRect(x: 0.0, y: y, width: width, height: height)
        return rect
    }
    
    func innerCardViewRect() -> CGRect {
        let rect = CGRect(x: 0.0, y: 0.0, width: cardView.frame.width, height: cardView.frame.height)
        return rect
    }
    
    func addImageView() {
        let rect = innerCardViewRect()
        mailImageView = UIImageView(frame: rect)
        mailImageView.image = mailImage
        cardView.addSubview(mailImageView)
        
    }
    
    func createCardBack() {
        let rect = innerCardViewRect()
        cardBack = UIView(frame: rect)
        cardBack.backgroundColor = UIColor.whiteColor()
        addFromAvatar()
        addFromLabel()
        addDateLabels()
        addToLabel()
        addBorder()
        addContents()
    }
    
    func addFromAvatar() {
        let rect = CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0)
        
        fromView = UIView(frame: rect)
        fromView.backgroundColor = slowpostDarkGrey
        fromView.layer.cornerRadius = 15
        cardBack.addSubview(fromView)
        
        let initialsRect = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        fromViewInitials = UILabel(frame: initialsRect)
        fromViewInitials.text = fromPerson.initials()
        fromViewInitials.font = UIFont(name: "OpenSans-Semibold", size: 13.0)
        fromViewInitials.textColor = UIColor.whiteColor()
        fromViewInitials.textAlignment = .Center
        fromView.addSubview(fromViewInitials)
    }
    
    func addFromLabel() {
        let rect = CGRect(x: 45.0, y: 14.0, width: view.frame.width - 45, height: 24.0)
        fromLabel = UILabel(frame: rect)
        fromLabel.text = fromPerson.fullName()
        fromLabel.font = UIFont(name: "OpenSans-Light", size: 17.0)
        fromLabel.textColor = slowpostBlack
        cardBack.addSubview(fromLabel)
    }
    
    func addDateLabels() {
        let dateRect = CGRect(x: 45.0, y: 38.0, width: view.frame.width - 45, height: 17.0)
        dateLabel = UILabel(frame: dateRect)
        let sentDateString = mail.dateSent.formattedAsString("yyyy-MM-dd")
        if mail.status != "SENT" {
            let deliveredDateString = mail.dateDelivered.formattedAsString("yyyy-MM-dd")
            dateLabel.text = "Sent \(sentDateString), delivered \(deliveredDateString)"
        }
        else {
            dateLabel.text = "Sent on \(sentDateString)"
        }
        dateLabel.font = UIFont(name: "OpenSans-Italic", size: 13.0)
        dateLabel.textColor = slowpostDarkGrey
        dateLabel.minimumScaleFactor = 0.6
        cardBack.addSubview(dateLabel)
    }
    
    func addToLabel() {
        let rect = CGRect(x: 10.0, y: 55.0, width: view.frame.width, height: 17.0)
        toLabel = UILabel(frame: rect)
        toLabel.text = "To: \(mail.toList())"
        toLabel.font = UIFont(name: "OpenSans", size: 13.0)
        toLabel.textColor = slowpostBlack
        toLabel.numberOfLines = 0
        cardBack.addSubview(toLabel)
    }
    
    func addBorder() {
        cardTextBorder = UIView()
        cardTextBorder.backgroundColor = slowpostLightGrey
        cardBack.addSubview(cardTextBorder)
        
        let leadingBorder = NSLayoutConstraint(item: cardTextBorder, attribute: .Leading, relatedBy: .Equal, toItem: cardBack, attribute: .Leading, multiplier: 1.0, constant: 10.0)
        let trailingBorder = NSLayoutConstraint(item: cardTextBorder, attribute: .Trailing, relatedBy: .Equal, toItem: cardBack, attribute: .Trailing, multiplier: 1.0, constant: -10.0)
        let borderHeight = NSLayoutConstraint(item: cardTextBorder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2.0)
        let borderTop = NSLayoutConstraint(item: cardTextBorder, attribute: .Top, relatedBy: .Equal, toItem: toLabel, attribute: .Bottom, multiplier: 1.0, constant: 5.0)
        cardTextBorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([leadingBorder, trailingBorder, borderHeight, borderTop])
    }
    
    func addContents() {
        contents = UILabel()
        contents.text = mail.content()
        cardBack.addSubview(contents)
        contents.font = UIFont(name: "OpenSans-Light", size: 17.0)
        contents.textColor = slowpostBlack
        contents.numberOfLines = 0
        contents.minimumScaleFactor = 0.6
        contents.adjustsFontSizeToFitWidth = true
        
        let leadingContents = NSLayoutConstraint(item: contents, attribute: .Leading, relatedBy: .Equal, toItem: cardBack, attribute: .Leading, multiplier: 1.0, constant: 10.0)
        let trailingContents = NSLayoutConstraint(item: contents, attribute: .Trailing, relatedBy: .Equal, toItem: cardBack, attribute: .Trailing, multiplier: 1.0, constant: -10.0)
        let topContents = NSLayoutConstraint(item: contents, attribute: .Top, relatedBy: .Equal, toItem: cardTextBorder, attribute: .Bottom, multiplier: 1.0, constant: 5.0)
        let bottomContents = NSLayoutConstraint(item: contents, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: cardBack, attribute: .Bottom, multiplier: 1.0, constant: -10.0)
        contents.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([leadingContents, trailingContents, topContents, bottomContents])
    }
    
    func tapped() {
        if displayingFront == true {
            UIView.transitionFromView(mailImageView, toView: cardBack, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            displayingFront = false
        }
        else {
            UIView.transitionFromView(cardBack, toView: mailImageView, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            displayingFront = true
        }
    }
    
    func readMailIfNecessary() {
        if mail.myStatus != "READ" && mail.toLoggedInUser() {
            mail.markAsRead()
            let readMailURL = "\(PostOfficeURL)/mail/id/\(mail.id)/read"
            RestService.postRequest(readMailURL, parameters: nil, headers: nil, completion: { (error, result) -> Void in
                if error != nil {
                    print(error)
                }
            })
        }
    }
    
    @IBAction func replyToMail(sender: AnyObject) {
        Flurry.logEvent("Replied_to_mail")
        var toPeople = [Person]()
        let userId = LoginService.getUserIdFromToken()
        for item in mail.conversation.people.allObjects {
            let person = item as! Person
            if person.id != userId {
                toPeople.append(person)
            }
        }
        var toEmails = [String]()
        for item in mail.conversation.emails.allObjects {
            let emailAddress = item as! EmailAddress
            toEmails.append(emailAddress.email)
        }

        let storyboard = UIStoryboard(name: "compose", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ComposeNavigationController!
        controller.toPeople = toPeople
        controller.toSearchPeople = [SearchPerson]()
        controller.toEmails = toEmails
        presentViewController(controller, animated: true, completion: {})
        
    }
    
    func closeMailView() {
        print("Close pressed")
        if runOnClose != nil { runOnClose!() }
        dismissViewControllerAnimated(true, completion: {})
    }
}

