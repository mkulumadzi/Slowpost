//
//  ChooseImageAndComposeMailViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 12/10/15.
//  Copyright © 2015 Evan Waters. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import SwiftyJSON
import Alamofire

class ChooseImageAndComposeMailViewController: BaseViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    var newMedia: Bool?
    var imageSelected:UIImage!
    var cardUrls:[String]!
    var overlayUrls:[String]!
    var cardPhotos = [UIImage]()
    var cardOverlays = [[String: AnyObject]]()
    var fetchResult:PHFetchResult!
    var clearPhotoButton:UIButton!
    var textEntered:String!
    var composeView:ComposeView!
    var imageContainerView:UIView!
    var imageContainerHeight:NSLayoutConstraint!
    var imageView:UIImageView!
    var composeViewBottom:NSLayoutConstraint!
    var composeTopBorder:UIView!
    var composeTopBorderDefaultTop:NSLayoutConstraint!
    var composeTextView:UITextView!
    var placeholderText:UILabel!
    var doneEditingButton:UIButton!
    var sendButtonView:UIView!
    var sendButtonLabel:UILabel!
    var scheduledToArrive:NSDate?
    var shadedView:UIView!
    var leadingCardOverlayContainer:NSLayoutConstraint!
    var cardOverlayContainer:OverlayContainerView!
    var overlayIndex:Int!
    var overlaysAllowed:Bool!
    var overlayInstructions:UILabel!
    var deliveryMethod:String!
    var shouldAdjustComposeHeight:Bool!
    
    @IBOutlet weak var photoLibrary: UIButton!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var textOnly: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getRecipientsFromNavController()
        getCards()
        configure()
        setDefaultDeliveryMethod()
        resignFirstResponder()
        
    }
    
    //MARK: Setup
    
    private func configure() {
        toLabel.text = toList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        formatButtons()
        initializeClearPhotoButton()
        initializeDoneEditingButton()
        initializeSendButton()
        initializeShadedView()
        initializeCardOverlays()
        addWarningLabel()
    }
    
    private func formatButtons() {
        cancelButton.setImage(UIImage(named: "chevron-down")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        cancelButton.tintColor = UIColor.whiteColor()
        
        photoLibrary.setImage(UIImage(named: "photo-library")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        photoLibrary.tintColor = slowpostDarkGreen

        
        takePhoto.setImage(UIImage(named: "camera")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        takePhoto.tintColor = slowpostDarkGreen
        
        textOnly.setImage(UIImage(named: "text")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        textOnly.tintColor = slowpostDarkGreen
    }
    
    private func initializeClearPhotoButton() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        clearPhotoButton = UIButton(frame: rect)
        clearPhotoButton.setImage(UIImage(named: "remove")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        clearPhotoButton.tintColor = UIColor.whiteColor()
        clearPhotoButton.addTarget(self, action: "clearComposeView", forControlEvents: .TouchUpInside)
        
    }
    
    private func initializeDoneEditingButton() {
        doneEditingButton = UIButton.standardTextButton("Done", target: self, action: "doneEditing")
        view.addSubview(doneEditingButton)
        doneEditingButton.hidden = true
    }
    
    private func initializeSendButton() {
        sendButtonView = view.newSubview(slowpostDarkGreen, cornerRadius: nil)
        pinItemToBottomWithHeight(sendButtonView, toItem: view, height: 60.0)
        
        sendButtonLabel = UILabel()
        sendButtonView.addSubview(sendButtonLabel)
        sendButtonLabel.font = UIFont(name: "OpenSans-Semibold", size: 15.0)
        sendButtonLabel.textColor = UIColor.whiteColor()
        centerVerticallyPinTrailing(sendButtonLabel, toItem: sendButtonView, trailingConstant: -10.0)
        
        let sendMask = UIButton()
        sendButtonView.addSubview(sendMask)
        sendMask.backgroundColor = UIColor.clearColor()
        sendMask.addTarget(self, action: "sendTapped", forControlEvents: .TouchUpInside)
        addConstraintsForItemInContainer(sendMask, toItem: sendButtonView, leadingConstant: 80.0, trailingConstant: 0.0, topConstant: 0.0, bottomConstant: 0.0)
        
        let scheduleDeliveryButton = UIButton.textButton(UIColor.clearColor(), title: "Options", textColor: UIColor.whiteColor(), target: self, action: "scheduleDelivery")
        sendButtonView.addSubview(scheduleDeliveryButton)

        
        let scheduleDeliveryConstraints = [
            NSLayoutConstraint.leading(scheduleDeliveryButton, toItem: sendButtonView, constant: 0.0),
            NSLayoutConstraint.trailingToLeading(scheduleDeliveryButton, toItem: sendMask, constant: 0.0),
            NSLayoutConstraint.top(scheduleDeliveryButton, toItem: sendButtonView, constant: 0.0),
            NSLayoutConstraint.bottom(scheduleDeliveryButton, toItem: sendButtonView, constant: 0.0)
        ]
        activateConstraintsForItem(scheduleDeliveryButton, constraints: scheduleDeliveryConstraints)
        
        sendButtonView.hidden = true
    }
    
    func initializeShadedView() {
        shadedView = UIView(frame: view.frame)
        shadedView.backgroundColor = slowpostBlack
        shadedView.alpha = 0.5
        view.addSubview(shadedView)
        shadedView.hidden = true
    }
    
    private func validateSendAndPlaceholder() {
        if composeTextView.text != nil && composeTextView.text != "" {
            sendButtonView.hidden = false
            formatSendButton()
            view.bringSubviewToFront(sendButtonView)
            placeholderText.hidden = true
        }
        else {
            sendButtonView.hidden = true
            placeholderText.hidden = false
        }
    }
    
    //Recipients and ToList configuration
    
    private func getRecipientsFromNavController() {
        if let navController = navigationController as? ComposeNavigationController {
            toPeople = navController.toPeople
            toSearchPeople = navController.toSearchPeople
            toEmails = navController.toEmails
        }
    }
    
    private func toList() -> String {
        var toList = ""
        var index = 0
        for person in toPeople {
            if index > 0 { toList += ", " }
            toList += person.fullName()
            index += 1
        }
        for searchPerson in toSearchPeople {
            if index > 0 { toList += ", " }
            toList += searchPerson.fullName()
            index += 1
        }
        for email in toEmails {
            if index > 0 { toList += ", " }
            toList += email
            index += 1
        }
        return toList
    }
    
    // Getting images
    
    private func numCards() -> CGFloat {
        let width = Double(view.frame.width)
        let size = Double(160.0)
        let numPhotos = CGFloat(round(width / size))
        return numPhotos
    }
    
    private func getCards() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        let cardsURL = "\(PostOfficeURL)cards"
        
        RestService.getRequest(cardsURL, headers: nil, completion: { (error, result) -> Void in
            if let error = error {
                print(error)
            }
            else {
                if let cardArray = result as? [String] {
                    self.cardUrls = cardArray
                    self.populateCardPhotos()
                }
                else {
                    print("Unexpected JSON result getting cards")
                }
            }
        })
    }
    
    private func populateCardPhotos() {
        
        for url in cardUrls {
            // First check for local file, use that if it is found
            let cardName = url.characters.split{$0 == "/"}.map(String.init).last
            let imageFile = FileService.getImageFromDirectory(cardName)
            if let imageFile = imageFile {
                self.cardPhotos.append(imageFile)
                self.photoCollection.reloadData()
            }
            else {
                let newCardName = url.stringByReplacingOccurrencesOfString(" ", withString: "%20")
                let imageURL = "\(PostOfficeURL)/image/\(newCardName)"
                FileService.downloadImage(imageURL, completion: { (error, result) -> Void in
                    if let error = error {
                        print(error)
                    }
                    else if let image = result as? UIImage {
                        FileService.saveImageToDirectory(image, fileName: cardName)
                        self.cardPhotos.append(image)
                        self.photoCollection.reloadData()
                    }
                })
            }
            stopActivityIndicator()
        }
        
    }
    
    private func stopActivityIndicator() {
        if activityIndicator.isAnimating() {
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
        }
    }
    
    // Card overlays
    
    private func initializeCardOverlays() {
        let overlaysURL = "\(PostOfficeURL)overlays"
        
        RestService.getRequest(overlaysURL, headers: nil, completion: { (error, result) -> Void in
            if let error = error {
                print(error)
            }
            else {
                if let overlayArray = result as? [String] {
                    print(overlayArray)
                    self.overlayUrls = overlayArray
                    self.populateOverlayPhotos()
                }
                else {
                    print("Unexpected JSON result getting cards")
                }
            }
        })
    }
    
    private func populateOverlayPhotos() {
        for url in overlayUrls {
            let overlayName = url.characters.split{$0 == "/"}.map(String.init).last
            let imageFile = FileService.getImageFromDirectory(overlayName)
            if let imageFile = imageFile {
                self.addCardOverlay(imageFile, name: overlayName)
            }
            else {
                let newOverlayName = url.stringByReplacingOccurrencesOfString(" ", withString: "%20")
                let imageURL = "\(PostOfficeURL)/image/\(newOverlayName)"
                print(imageURL)
                FileService.downloadImage(imageURL, completion: { (error, result) -> Void in
                    if let error = error {
                        print(error)
                    }
                    else if let image = result as? UIImage {
                        FileService.savePNGToDirectory(image, fileName: overlayName)
                        self.addCardOverlay(image, name: overlayName)
                    }
                })
            }
        }
    }
    
    private func addCardOverlay(image: UIImage, name: String) {
        let edge = name.characters.split{$0 == "-"}.map(String.init).first!.uppercaseString
        cardOverlays.append(["image": image, "edge": edge])
    }
    
    // Configure image picker view
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == (kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            Flurry.logEvent("Got_Image_From_Camera")
            overlaysAllowed = true
            imageSelected = image
            addComposeView()
            
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            } else if mediaType == (kUTTypeMovie as String) {
                // Code to support video here
            }
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    

    // Collection view configuration
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        var width:CGFloat!
        var height:CGFloat!
        let num = numCards()
        let spaces = (num + 1) * 5
        width = (view.frame.width - spaces) / num
        height = width
        return CGSize.init(width: width, height: height)
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        var image:UIImage!
        image = cardPhotos[indexPath.row]
        cell.cellImage.image = image
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var image:UIImage!
        image = cardPhotos[indexPath.row]
        let parameters:[String: String] = ["Name": cardUrls[indexPath.row]]
        Flurry.logEvent("Chose_Image_From_Gallery", withParameters: parameters)
        overlaysAllowed = false
        imageSelected = image
        addComposeView()
    }
    
    
    // Set up compose view
    
    private func addComposeView() {
        composeView = ComposeView()
        composeView.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(composeView)
        
        let top = NSLayoutConstraint(item: composeView, attribute: .Top, relatedBy: .Equal, toItem: toLabel, attribute: .Bottom, multiplier: 1.0, constant: 10.0)
        let leading = NSLayoutConstraint(item: composeView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: composeView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        composeViewBottom = NSLayoutConstraint(item: composeView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        composeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([top, leading, trailing, composeViewBottom])
        
        if imageSelected != nil {
            let imageContainerView = addImageContainerView()
            addComposeTextView(imageContainerView)
        }
        else {
            let imageOptionView = addImageOptionView()
            addComposeTextView(imageOptionView)
        }
        
        validateSendAndPlaceholder()
        
    }
    
    private func addImageContainerView() -> UIView {
        imageContainerView = composeView.newSubview(UIColor.lightGrayColor(), cornerRadius: nil)
        let suggestedImageHeight = view.frame.width * imageSelected.size.height / imageSelected.size.width
        var maxImageHeight:CGFloat!
        if view.frame.height - suggestedImageHeight < 240.0 {
            print("Setting gap to 80")
            maxImageHeight = view.frame.height - 240.0
        }
        else {
            print("Using suggested height")
            maxImageHeight = suggestedImageHeight
        }
        pinItemToTopWithHeight(imageContainerView, toItem: composeView, height: maxImageHeight)
        
        imageView = UIImageView(image: imageSelected)
        composeView.addSubview(imageView)
        let aspectRatio = imageSelected.size.width / imageSelected.size.height
        let topImage = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: composeView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomImage = NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: imageContainerView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let alignImage = NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: imageContainerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let imageAspectRatio = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: aspectRatio, constant: 0.0)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([topImage, bottomImage, alignImage, imageAspectRatio])
        
        if overlaysAllowed == true {
            addOverlayContainer(maxImageHeight)
        }
        
        let clearButtonBackground = composeView.newSubview(UIColor.darkGrayColor(), cornerRadius: 10.0)
        
        let topClearBackground = NSLayoutConstraint(item: clearButtonBackground, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1.0, constant: 10.0)
        let leadingClearBackground = NSLayoutConstraint(item: clearButtonBackground, attribute: .Leading, relatedBy: .Equal, toItem: imageView, attribute: .Leading, multiplier: 1.0, constant: 10.0)
        let clearBackgroundWidth = NSLayoutConstraint(item: clearButtonBackground, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20.0)
        let clearBackgroundHeight = NSLayoutConstraint(item: clearButtonBackground, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20.0)
        
        clearButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([topClearBackground, leadingClearBackground, clearBackgroundWidth, clearBackgroundHeight])
        
        clearButtonBackground.addSubview(clearPhotoButton)
        
        return imageContainerView
    }
    
    private func addOverlayContainer(maxImageHeight: CGFloat) {
        cardOverlayContainer = OverlayContainerView()
        composeView.addSubview(cardOverlayContainer)
        cardOverlayContainer.backgroundColor = UIColor.clearColor()
        
        let topCardOverlayContainer = NSLayoutConstraint(item: cardOverlayContainer, attribute: .Top, relatedBy: .Equal, toItem: composeView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        leadingCardOverlayContainer = NSLayoutConstraint(item: cardOverlayContainer, attribute: .Leading, relatedBy: .Equal, toItem: composeView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let heightCardOverlayContainer = NSLayoutConstraint(item: cardOverlayContainer, attribute: .Height, relatedBy: .Equal, toItem: imageContainerView, attribute: .Height, multiplier: 1.0, constant: 0.0)
        let widthCardOverlayContainer = NSLayoutConstraint(item: cardOverlayContainer, attribute: .Width, relatedBy: .Equal, toItem: imageContainerView, attribute: .Width, multiplier: CGFloat(cardOverlays.count + 1), constant: 0.0)
        cardOverlayContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([topCardOverlayContainer, leadingCardOverlayContainer, heightCardOverlayContainer, widthCardOverlayContainer])
        
        addCardOverlayImages(maxImageHeight)
        
        overlayInstructions = UILabel()
        composeView.addSubview(overlayInstructions)
        overlayInstructions.text = "Swipe to add overlay image"
        overlayInstructions.font = UIFont(name: "OpenSans-Italic", size: 15.0)
        overlayInstructions.textAlignment = .Center
        overlayInstructions.textColor = UIColor.whiteColor()
        overlayInstructions.backgroundColor = slowpostDarkGrey
        pinItemToBottom(overlayInstructions, toItem: imageContainerView)
        
        overlayIndex = 0
        let overlaySwipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeLeft:"))
        overlaySwipeLeft.direction = .Left
        overlaySwipeLeft.delegate = self
        cardOverlayContainer.addGestureRecognizer(overlaySwipeLeft)
        
        let overlaySwipeRight = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeRight:"))
        overlaySwipeRight.direction = .Right
        overlaySwipeRight.delegate = self
        cardOverlayContainer.addGestureRecognizer(overlaySwipeRight)
    }
    
    private func addCardOverlayImages(maxImageHeight: CGFloat) {
        let renderedImageWidth = imageSelected.size.width * maxImageHeight / imageSelected.size.height
        var offsetIndex = CGFloat(1.0)
        for overlayImageDictionary in cardOverlays {
            
            let overlayImage = (overlayImageDictionary["image"] as? UIImage)!
            var edge:NSLayoutAttribute!
            let edgeString = overlayImageDictionary["edge"] as! String
            if edgeString == "TOP" {
                edge = NSLayoutAttribute.Top
            } else {
                edge = NSLayoutAttribute.Bottom
            }
            
            let leadingConstant = offsetIndex * view.frame.width + (view.frame.width - renderedImageWidth) / 2
            print(leadingConstant)
            
            let overlay = UIImageView(image: overlayImage)
            overlay.backgroundColor = UIColor.clearColor()
            cardOverlayContainer.addSubview(overlay)
            let overlayWidth = NSLayoutConstraint(item: overlay, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1.0, constant: 0.0)
            let overlayHeight = NSLayoutConstraint(item: overlay, attribute: .Height, relatedBy: .Equal, toItem: overlay, attribute: .Width, multiplier: (overlayImage.size.height / overlayImage.size.width), constant: 0.0)
            let overlayEdge = NSLayoutConstraint(item: overlay, attribute: edge, relatedBy: .Equal, toItem: imageContainerView, attribute: edge, multiplier: 1.0, constant: 1.0)
            let overlayLeading = NSLayoutConstraint(item: overlay, attribute: .Leading, relatedBy: .Equal, toItem: cardOverlayContainer, attribute: .Leading, multiplier: 1.0, constant: leadingConstant)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints([overlayWidth, overlayHeight, overlayEdge, overlayLeading])
            offsetIndex += CGFloat(1.0)
        }

    }
    
    private func addImageOptionView() -> UIView {
        let imageOptionView = composeView.newSubview(UIColor.whiteColor(), cornerRadius: nil)
        pinItemToTopWithHeight(imageOptionView, toItem: composeView, height: 40.0)
        
        let imageOptionButton = UIButton.standardTextButton("Add image", target: self, action: "clearComposeView")
        imageOptionView.addSubview(imageOptionButton)
        embedItem(imageOptionButton, toItem: imageOptionView)
        
        return imageOptionView
    }
    
    func handleSwipeLeft(recognizer: UISwipeGestureRecognizer) {
        if overlayInstructions.hidden == false {
            UIView.animateWithDuration(0.5, animations: {
                self.overlayInstructions.hidden = true
            })
        }
        leadingCardOverlayContainer.constant -= view.frame.width
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.overlayIndex = self.overlayIndex + 1
            }, completion: { _ -> Void in
                if self.overlayIndex > self.cardOverlays.count {
                    self.leadingCardOverlayContainer.constant = 0
                    self.view.layoutIfNeeded()
                    self.overlayIndex = 0
                }
        })
    }
    
    func handleSwipeRight(recognizer: UISwipeGestureRecognizer) {
        if overlayInstructions.hidden == false {
            UIView.animateWithDuration(0.5, animations: {
                self.overlayInstructions.hidden = true
            })
        }
        if overlayIndex == 0 {
            leadingCardOverlayContainer.constant = -(view.frame.width * CGFloat(cardOverlays.count + 1))
            view.layoutIfNeeded()
            overlayIndex = cardOverlays.count + 1
        }
        leadingCardOverlayContainer.constant += view.frame.width
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.overlayIndex = self.overlayIndex - 1
            }, completion: nil)
    }

    
    private func addComposeTextView(topView: UIView) {
        composeTopBorder = composeView.newSubview(UIColor.darkGrayColor(), cornerRadius: nil)
        composeTopBorderDefaultTop = NSLayoutConstraint(item: composeTopBorder, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leadingBorder = NSLayoutConstraint(item: composeTopBorder, attribute: .Leading, relatedBy: .Equal, toItem: composeView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingBorder = NSLayoutConstraint(item: composeTopBorder, attribute: .Trailing, relatedBy: .Equal, toItem: composeView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let borderHeight = NSLayoutConstraint(item: composeTopBorder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 3.0)
        
        composeTopBorderDefaultTop.priority = 999
        
        composeTopBorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([composeTopBorderDefaultTop, leadingBorder, trailingBorder, borderHeight])
        
        composeTextView = UITextView()
        if textEntered != nil {
            composeTextView.text = textEntered
        }
        composeTextView.font = UIFont(name: "OpenSans", size: 17.0)
        composeTextView.textColor = slowpostBlack
        composeView.addSubview(composeTextView)
        
        let topCompose = NSLayoutConstraint(item: composeTextView, attribute: .Top, relatedBy: .Equal, toItem: composeTopBorder, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leadingCompose = NSLayoutConstraint(item: composeTextView, attribute: .Leading, relatedBy: .Equal, toItem: composeView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingCompose = NSLayoutConstraint(item: composeTextView, attribute: .Trailing, relatedBy: .Equal, toItem: composeView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let bottomCompose = NSLayoutConstraint(item: composeTextView, attribute: .Bottom, relatedBy: .Equal, toItem: composeView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        composeTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([topCompose, leadingCompose, trailingCompose, bottomCompose])
        
        placeholderText = UILabel()
        composeTextView.addSubview(placeholderText)
        placeholderText.text = "Compose your message"
        placeholderText.font = UIFont(name: "OpenSans-Italic", size: 15.0)
        placeholderText.textColor = slowpostLightGrey
        
        let topPlaceholder = NSLayoutConstraint(item: placeholderText, attribute: .Top, relatedBy: .Equal, toItem: composeTextView, attribute: .Top, multiplier: 1.0, constant: 10.0)
        let leadingPlaceholder = NSLayoutConstraint(item: placeholderText, attribute: .Leading, relatedBy: .Equal, toItem: composeTextView, attribute: .Leading, multiplier: 1.0, constant: 10.0)
        let placeholderHeight = NSLayoutConstraint(item: placeholderText, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 21)
        placeholderText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([topPlaceholder, leadingPlaceholder, placeholderHeight])
        
        shouldAdjustComposeHeight = true

    }
    
    // Modifying view when keyboard is shown
    
    func keyboardShow(notification: NSNotification) {
        if shouldAdjustComposeHeight == true {
            if self.imageSelected != nil {
                self.composeTopBorderDefaultTop.constant -= self.imageContainerView.frame.height
            }
            else {
                self.composeTopBorderDefaultTop.constant -= 40.0
            }
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            
            let userInfo = notification.userInfo!
            var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            r = composeTextView.convertRect(r, fromView:nil)
            composeTextView.contentInset.bottom = r.size.height + 60.0
            composeTextView.scrollIndicatorInsets.bottom = r.size.height + 60.0
            
            placeholderText.hidden = true
            shouldAdjustComposeHeight = false
        }

    }
    
    func keyboardHide(notification:NSNotification) {
        if imageSelected != nil {
            self.composeTopBorderDefaultTop.constant += self.imageContainerView.frame.height
        }
        else {
            self.composeTopBorderDefaultTop.constant += 40.0
        }
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        doneEditingButton.hidden = true
        validateSendAndPlaceholder()
        composeTextView.scrollRangeToVisible(NSMakeRange(0,0))
        shouldAdjustComposeHeight = true
    }
    
    func keyboardDidHide(notification:NSNotification) {
    }
    
    func keyboardDidShow(notification:NSNotification) {
        
        view.bringSubviewToFront(doneEditingButton)
        
        let userInfo = notification.userInfo!
        var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = composeTextView.convertRect(r, fromView:nil)
        let y = view.frame.height - r.size.height - 40.0
        
        doneEditingButton.frame = CGRect(x: 0, y: y, width: view.frame.width, height: 40.0)
        doneEditingButton.hidden = false
    }
    
    //MARK: User Actions
    
    // Photo Library
    
    @IBAction func goToPhotoLibrary(sender: AnyObject) {
        Flurry.logEvent("Chose_To_Select_Photo_From_Library")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            imagePicker.navigationBar.tintColor = UIColor.whiteColor()
            imagePicker.navigationBar.barTintColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
            
            presentViewController(imagePicker, animated: true, completion: nil)
            newMedia = false
        }
    }
    
    // Camera configuration
    
    @IBAction func takePhoto(sender: AnyObject) {
        Flurry.logEvent("Chose_To_Take_Picture")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            presentViewController(imagePicker, animated: true, completion: nil)
            newMedia = true
        }
    }
    
    // Scheduling delivery
    
    func scheduleDelivery() {
        performSegueWithIdentifier("scheduleDelivery", sender: nil)
    }
    
    @IBAction func deliveryOptionChosen(segue: UIStoryboardSegue) {
        shadedView.hidden = true
        formatSendButton()
    }
    
    @IBAction func deliveryOptionsCancelled(segue: UIStoryboardSegue) {
        shadedView.hidden = true
    }
    
    // Person does not want to send a photo
    @IBAction func textOnlyOptionSelected(sender: AnyObject) {
        imageSelected = nil
        addComposeView()
    }
    
    func rotated() {
        view.layoutIfNeeded()
    }
    
    func doneEditing() {
        view.endEditing(true)
    }
    
    func sendTapped() {
        performSegueWithIdentifier("sendMail", sender: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    func clearComposeView() {
        for subview in view.subviews {
            if let composeView = subview as? ComposeView {
                for childview in composeView.subviews {
                    if let composeTextView = childview as? UITextView {
                        textEntered = composeTextView.text
                    }
                }
                composeView.removeFromSuperview()
            }
        }
        sendButtonView.hidden = true
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sendMail" {
            let sendingViewController = segue.destinationViewController as? SendingViewController
            sendingViewController!.toPeople = toPeople
            sendingViewController!.toSearchPeople = toSearchPeople
            sendingViewController!.toEmails = toEmails
            sendingViewController!.content = composeTextView.text
            sendingViewController!.deliveryMethod = deliveryMethod
            
            if imageSelected != nil {
                var imageToSend:UIImage!
                if overlayIndex != nil {
                    if overlayIndex > 0 {
                        imageToSend = mergeImages(imageSelected, index: overlayIndex - 1)
                    }
                    else {
                        imageToSend = imageSelected
                    }
                }
                else {
                    imageToSend = imageSelected
                }
                
                sendingViewController!.image = imageToSend
            }
            if let scheduledToArrive = scheduledToArrive {
                sendingViewController!.scheduledToArrive = scheduledToArrive
            }
        }
        else if segue.identifier == "scheduleDelivery" {
            let chooseDeliveryOptions = segue.destinationViewController as! ChooseDeliveryOptionsViewController
            chooseDeliveryOptions.deliveryMethod = self.deliveryMethod
            initializeShadedView()
            view.bringSubviewToFront(shadedView)
            shadedView.hidden = false
        }
    }
    
    @IBAction func mailFailedToSend(segue: UIStoryboardSegue) {
    }
    
    @IBAction func notReadyToSend(segue: UIStoryboardSegue) {
    }
    
    //MARK: Private
    
    private func setDefaultDeliveryMethod() {
        deliveryMethod = "express"
        let userId = LoginService.getUserIdFromToken()
        let defaultsUrl = "\(PostOfficeURL)/person/id/\(userId)/defaults"
        let headers = ["Authorization": RestService.addAuthHeader()]
        Alamofire.request(.GET, defaultsUrl, headers: headers).responseJSON { (response) in
            switch response.result {
            case .Failure:
                print("Error getting defaults")
            case .Success:
                let json = JSON(response.result.value!)
                self.deliveryMethod = json["default_delivery_method"].stringValue
                print(self.deliveryMethod)
            }
        }
    }
    
    private func formatSendButton() {
        print("formattingSendButton")
        switch deliveryMethod {
        case "express":
            sendButtonLabel.text = "Send now >>"
        case "scheduled":
            let dateString = scheduledToArrive!.formattedAsString("yyyy-MM-dd")
            sendButtonLabel.text = "Send (arrives on \(dateString)) >>"
        default:
            sendButtonLabel.text = "Send (arrives in 1 to 2 days) >>"
        }
    }
    
    private func mergeImages(bottomImage: UIImage, index: Int) -> UIImage {
        let topImage = cardOverlays[index]["image"] as! UIImage
        let edge = cardOverlays[index]["edge"] as! String
        
        let size = bottomImage.size
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage.drawInRect(areaSize)
        
        let topWidth = size.width
        let topHeight = topImage.size.height * size.width / topImage.size.width
        var offset:CGFloat!
        if edge == "TOP" {
            offset = 0.0
        }
        else {
            offset = size.height - topHeight
        }
        let topSize = CGRect(x: 0, y: offset, width: topWidth, height: topHeight)
        topImage.drawInRect(topSize, blendMode: .Normal, alpha: 1.0)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }


}
