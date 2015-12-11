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

class ChooseImageAndComposeMailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var toPeople:[Person]!
    var toSearchPeople:[SearchPerson]!
    var toEmails:[String]!
    var newMedia: Bool?
    var imageSelected:UIImage!
    var cardNames:[String]!
    var cardPhotos = [UIImage]()
    var userPhotos = [UIImage]()
    var fetchResult:PHFetchResult!
    var clearPhotoButton:UIButton!
    var textEntered:String!
    var defaultComposeViewBottom = NSLayoutConstraint()
    var sendComposeViewBottom = NSLayoutConstraint()
    var composeTopBorder = UIView()
    var composeTopBorderDefaultTop = NSLayoutConstraint()
    var composeTopBorderKeyboardTop = NSLayoutConstraint()
    var composeTextView = UITextView()
    var placeholderText = UILabel()
    var doneEditingButton:UIButton!
    var sendButtonView = UIView()
    var sendButtonLabel = UILabel()
    var warningLabel = WarningUILabel()
    var scheduledToArrive:NSDate?
    var shadedView:UIView!
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRecipientsFromNavController()
        toLabel.text = toList()
        segmentedControl.addTarget(self, action:"toggleResults", forControlEvents: .ValueChanged)
        getCards()
        getImagesFromCameraRoll()
        
        initializeClearPhotoButton()
        initializeDoneEditingButton()
        initializeSendButton()
        initializeWarningLabel()
        initializeShadedView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        resignFirstResponder()
        
    }
    
    // Initializing buttons
    
    func initializeClearPhotoButton() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        clearPhotoButton = UIButton(frame: rect)
        clearPhotoButton.setImage(UIImage(named: "remove")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        clearPhotoButton.tintColor = UIColor.whiteColor()
        clearPhotoButton.addTarget(self, action: "clearComposeView", forControlEvents: .TouchUpInside)
        
    }
    
    func clearComposeView() {
        print("Photo being cleared!")
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
    
    func initializeDoneEditingButton() {
        doneEditingButton = UIButton()
        view.addSubview(doneEditingButton)
        doneEditingButton.backgroundColor = slowpostDarkGreen
        doneEditingButton.setTitle("Done", forState: .Normal)
        doneEditingButton.titleLabel!.font = UIFont(name: "OpenSans-Semibold", size: 15.0)
        doneEditingButton.titleLabel!.textColor = UIColor.whiteColor()
        doneEditingButton.addTarget(self, action: "doneEditing", forControlEvents: .TouchUpInside)
        doneEditingButton.hidden = true
    }
    
    func doneEditing() {
        view.endEditing(true)
    }
    
    func initializeSendButton() {
        view.addSubview(sendButtonView)
        sendButtonView.backgroundColor = slowpostDarkGreen
        
        let sendLeading = NSLayoutConstraint(item: sendButtonView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let sendTrailing = NSLayoutConstraint(item: sendButtonView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let sendBottom = NSLayoutConstraint(item: sendButtonView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let sendHeight = NSLayoutConstraint(item: sendButtonView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 60.0)
        sendButtonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([sendLeading, sendTrailing, sendBottom, sendHeight])
        
        sendButtonView.addSubview(sendButtonLabel)
        sendButtonLabel.text = "Send now >>"
        sendButtonLabel.font = UIFont(name: "OpenSans-Semibold", size: 15.0)
        sendButtonLabel.textColor = UIColor.whiteColor()
        
        let labelHorizontal = NSLayoutConstraint(item: sendButtonLabel, attribute: .CenterY, relatedBy: .Equal, toItem: sendButtonView, attribute: .CenterY, multiplier: 1.0, constant: 1.0)
        let labelTrailing = NSLayoutConstraint(item: sendButtonLabel, attribute: .Trailing, relatedBy: .Equal, toItem: sendButtonView, attribute: .Trailing, multiplier: 1.0, constant: -10.0)
        sendButtonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([labelHorizontal, labelTrailing])
        
        let sendMask = UIButton()
        sendButtonView.addSubview(sendMask)
        sendMask.backgroundColor = UIColor.clearColor()
        sendMask.addTarget(self, action: "sendTapped", forControlEvents: .TouchUpInside)
        
        let sendMaskLeading = NSLayoutConstraint(item: sendMask, attribute: .Leading, relatedBy: .Equal, toItem: sendButtonView, attribute: .Leading, multiplier: 1.0, constant: 60.0)
        let sendMaskTrailing = NSLayoutConstraint(item: sendMask, attribute: .Trailing, relatedBy: .Equal, toItem: sendButtonView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let sendMaskTop = NSLayoutConstraint(item: sendMask, attribute: .Top, relatedBy: .Equal, toItem: sendButtonView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let sendMaskBottom = NSLayoutConstraint(item: sendMask, attribute: .Bottom, relatedBy: .Equal, toItem: sendButtonView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        sendMask.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([sendMaskLeading, sendMaskTrailing, sendMaskTop, sendMaskBottom])
        
        let scheduleDeliveryButton = UIButton()
        sendButtonView.addSubview(scheduleDeliveryButton)
        scheduleDeliveryButton.backgroundColor = UIColor.clearColor()
        scheduleDeliveryButton.setImage(UIImage(named: "calendar")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        scheduleDeliveryButton.tintColor = UIColor.whiteColor()
        scheduleDeliveryButton.addTarget(self, action: "scheduleDelivery", forControlEvents: .TouchUpInside)
        
        let scheduleLeading = NSLayoutConstraint(item: scheduleDeliveryButton, attribute: .Leading, relatedBy: .Equal, toItem: sendButtonView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let scheduleTrailing = NSLayoutConstraint(item: scheduleDeliveryButton, attribute: .Trailing, relatedBy: .Equal, toItem: sendMask, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let scheduleTop = NSLayoutConstraint(item: scheduleDeliveryButton, attribute: .Top, relatedBy: .Equal, toItem: sendButtonView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let scheduleBottom = NSLayoutConstraint(item: scheduleDeliveryButton, attribute: .Bottom, relatedBy: .Equal, toItem: sendButtonView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        scheduleDeliveryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([scheduleLeading, scheduleTrailing, scheduleTop, scheduleBottom])
        
        sendButtonView.hidden = true
    }
    
    func sendTapped() {
        performSegueWithIdentifier("sendMail", sender: nil)
    }
    
    func initializeWarningLabel() {
        view.addSubview(warningLabel)
        warningLabel.backgroundColor = slowpostBlack
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.font = UIFont(name: "OpenSans", size: 15.0)
        warningLabel.textAlignment = .Center
        
        let warningLeading = NSLayoutConstraint(item: warningLabel, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let warningTrailing = NSLayoutConstraint(item: warningLabel, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let warningTop = NSLayoutConstraint(item: warningLabel, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 60.0)
        let warningHeight = NSLayoutConstraint(item: warningLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30.0)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([warningLeading, warningTrailing, warningTop, warningHeight])
        
        warningLabel.hide()

    }
    
    func initializeShadedView() {
        shadedView = UIView(frame: view.frame)
        shadedView.backgroundColor = slowpostBlack
        shadedView.alpha = 0.5
        view.addSubview(shadedView)
        shadedView.hidden = true
    }
    
    //

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Recipients and ToList configuration
    
    func getRecipientsFromNavController() {
        if let navController = navigationController as? ComposeNavigationController {
            toPeople = navController.toPeople
            toSearchPeople = navController.toSearchPeople
            toEmails = navController.toEmails
        }
    }
    
    func toList() -> String {
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
    
    func getCards() {
        let cardsURL = "\(PostOfficeURL)cards"
        
        RestService.getRequest(cardsURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else {
                if let cardArray = result as? [String] {
                    self.cardNames = cardArray
                    self.populateCardPhotos()
                }
                else {
                    print("Unexpected JSON result getting cards")
                }
            }
        })
    }
    
    func populateCardPhotos() {
        
        for card in cardNames {
            let newCardName = card.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            let imageURL = "\(PostOfficeURL)/image/\(newCardName)"
            FileService.downloadImage(imageURL, completion: { (error, result) -> Void in
                if error != nil {
                    print(error)
                }
                else if let image = result as? UIImage {
//                    if self.activityIndicator.isAnimating() {
//                        self.activityIndicator.stopAnimating()
//                    }
                    self.cardPhotos.append(image)
                    self.photoCollection.reloadData()
                }
            })
        }
        
    }
    
    func getImagesFromCameraRoll() {
        
        let maxDimension = (photoCollection.frame.width - 30) / 2
        let targetSize: CGSize = CGSize(width: maxDimension, height: maxDimension)
        let contentMode: PHImageContentMode = .AspectFit
        let fetchOptions:PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 200
        fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
        
        fetchResult.enumerateObjectsUsingBlock {
            object, index, stop in
            
            let options = PHImageRequestOptions()
            options.synchronous = true
            options.deliveryMode = .HighQualityFormat
            
            PHImageManager.defaultManager().requestImageForAsset(object as! PHAsset, targetSize: targetSize, contentMode: contentMode, options: options) {
                image, info in
                self.userPhotos.append(image!)
            }
        }
    }
    
    func getFullSizePhoto(index: Int) -> UIImage {
        var image:UIImage!
        let object = fetchResult.objectAtIndex(index)
        let targetSize: CGSize = CGSize(width: 800.0, height: 800.0)
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.deliveryMode = .HighQualityFormat
        PHImageManager.defaultManager().requestImageForAsset(object as! PHAsset, targetSize: targetSize, contentMode: .AspectFit, options: options) {
            imageFetched, info in
            image = imageFetched
        }
        return image
    }
    
    func toggleResults() {
        photoCollection.reloadData()
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == (kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            Flurry.logEvent("Got_Image_From_Camera")
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
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    

    // Collection view configuration
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return userPhotos.count
        default:
            return cardPhotos.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        
        let maxDimension = (photoCollection.frame.width - 30) / 2
        var image:UIImage!
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            image = userPhotos[indexPath.row]
        default:
            image = cardPhotos[indexPath.row]
        }
        
        let imageAspectRatio = image.size.width / image.size.height
        
        var width:CGFloat!
        var height:CGFloat!
        
        if imageAspectRatio > 1 {
            width = maxDimension
            height = width / imageAspectRatio
        }
        else if imageAspectRatio < 1 {
            height = maxDimension
            width = maxDimension * imageAspectRatio
        }
        else {
            width = maxDimension
            height = maxDimension
        }
        
        return CGSize.init(width: width, height: height)
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        var image:UIImage!
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            image = userPhotos[indexPath.row]
        default:
            image = cardPhotos[indexPath.row]
        }
        
        cell.cellImage.image = image
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var image:UIImage!
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            image = getFullSizePhoto(indexPath.row)
        default:
            image = cardPhotos[indexPath.row]
            let parameters:[String: String] = ["Name": cardNames[indexPath.row]]
            Flurry.logEvent("Chose_Image_From_Gallery", withParameters: parameters)
        }
        imageSelected = image
        print("Image selected")
        addComposeView()
    }
    
    // Handling case where person does not want to send a photo
    
    
    @IBAction func textOnlyOptionSelected(sender: AnyObject) {
        imageSelected = nil
        addComposeView()
    }
    
    
    // Set up compose view
    
    func addComposeView() {
        let composeView = ComposeView()
        composeView.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(composeView)
        
        let top = NSLayoutConstraint(item: composeView, attribute: .Top, relatedBy: .Equal, toItem: toLabel, attribute: .Bottom, multiplier: 1.0, constant: 10.0)
        let leading = NSLayoutConstraint(item: composeView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: composeView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        defaultComposeViewBottom = NSLayoutConstraint(item: composeView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        sendComposeViewBottom = NSLayoutConstraint(item: composeView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 60.0)
        
        defaultComposeViewBottom.priority = 999
        sendComposeViewBottom.priority = 251
        
        composeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([top, leading, trailing, defaultComposeViewBottom, sendComposeViewBottom])
        
        if imageSelected != nil {
            let imageContainerView = addImageContainerView(composeView)
            addComposeTextView(composeView, topView: imageContainerView)
        }
        else {
            let imageOptionView = addImageOptionView(composeView)
            addComposeTextView(composeView, topView: imageOptionView)
        }
        
        validateSendAndPlaceholder()
        
    }
    
    func addImageContainerView(composeView: UIView) -> UIView {
        let imageContainerView = UIView()
        composeView.addSubview(imageContainerView)
        imageContainerView.backgroundColor = UIColor.lightGrayColor()
        
        let suggestedImageHeight = view.frame.width * imageSelected.size.height / imageSelected.size.width
        var maxImageHeight:CGFloat!
        
        if view.frame.height - suggestedImageHeight < 200.0 {
            print("Setting gap to 80")
            maxImageHeight = view.frame.height - 200.0
        }
        else {
            print("Using suggested height")
            maxImageHeight = suggestedImageHeight
        }
        
        let topImageContainer = NSLayoutConstraint(item: imageContainerView, attribute: .Top, relatedBy: .Equal, toItem: composeView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let leadingImageContainer = NSLayoutConstraint(item: imageContainerView, attribute: .Leading, relatedBy: .Equal, toItem: composeView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingImageContainer = NSLayoutConstraint(item: imageContainerView, attribute: .Trailing, relatedBy: .Equal, toItem: composeView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let imageContainerHeight = NSLayoutConstraint(item: imageContainerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: maxImageHeight)
        
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([topImageContainer, leadingImageContainer, trailingImageContainer, imageContainerHeight])
        
        let imageView = UIImageView(image: imageSelected)
        composeView.addSubview(imageView)
        let aspectRatio = imageSelected.size.width / imageSelected.size.height
        let topImage = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: composeView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomImage = NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: imageContainerView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let alignImage = NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: imageContainerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let imageAspectRatio = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: aspectRatio, constant: 1.0)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([topImage, bottomImage, alignImage, imageAspectRatio])
        
        let clearButtonBackground = UIView()
        clearButtonBackground.backgroundColor = UIColor.darkGrayColor()
        clearButtonBackground.layer.cornerRadius = 10
        composeView.addSubview(clearButtonBackground)
        
        let topClearBackground = NSLayoutConstraint(item: clearButtonBackground, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1.0, constant: 10.0)
        let leadingClearBackground = NSLayoutConstraint(item: clearButtonBackground, attribute: .Leading, relatedBy: .Equal, toItem: imageView, attribute: .Leading, multiplier: 1.0, constant: 10.0)
        let clearBackgroundWidth = NSLayoutConstraint(item: clearButtonBackground, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20.0)
        let clearBackgroundHeight = NSLayoutConstraint(item: clearButtonBackground, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20.0)
        
        clearButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([topClearBackground, leadingClearBackground, clearBackgroundWidth, clearBackgroundHeight])
        
        clearButtonBackground.addSubview(clearPhotoButton)
        
        return imageContainerView
    }
    
    func addImageOptionView(composeView: UIView) -> UIView {
        let imageOptionView = UIView()
        composeView.addSubview(imageOptionView)
        imageOptionView.backgroundColor = UIColor.whiteColor()
        
        let topOptionView = NSLayoutConstraint(item: imageOptionView, attribute: .Top, relatedBy: .Equal, toItem: composeView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let leadingOptionView = NSLayoutConstraint(item: imageOptionView, attribute: .Leading, relatedBy: .Equal, toItem: composeView, attribute: .Leading, multiplier: 1.0, constant: -1.0)
        let trailingOptionView = NSLayoutConstraint(item: imageOptionView, attribute: .Trailing, relatedBy: .Equal, toItem: composeView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let heightOptionView = NSLayoutConstraint(item: imageOptionView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0)
        imageOptionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([topOptionView, leadingOptionView, trailingOptionView, heightOptionView])
        
        let imageOptionButton = UIButton()
        imageOptionView.addSubview(imageOptionButton)
        imageOptionButton.backgroundColor = slowpostDarkGreen
        imageOptionButton.setTitle("Add image", forState: .Normal)
        imageOptionButton.titleLabel!.font = UIFont(name: "OpenSans-Semibold", size: 15.0)
        imageOptionButton.titleLabel!.textColor = UIColor.whiteColor()
        imageOptionButton.addTarget(self, action: "clearComposeView", forControlEvents: .TouchUpInside)
        let topOptionButton = NSLayoutConstraint(item: imageOptionButton, attribute: .Top, relatedBy: .Equal, toItem: imageOptionView, attribute: .Top, multiplier: 1.0, constant: 1.0)
        let leadingOptionButton = NSLayoutConstraint(item: imageOptionButton, attribute: .Leading, relatedBy: .Equal, toItem: imageOptionView, attribute: .Leading, multiplier: 1.0, constant: 1.0)
        let trailingOptionButton = NSLayoutConstraint(item: imageOptionButton, attribute: .Trailing, relatedBy: .Equal, toItem: imageOptionView, attribute: .Trailing, multiplier: 1.0, constant: 1.0)
        let bottomOptionButton = NSLayoutConstraint(item: imageOptionButton, attribute: .Bottom, relatedBy: .Equal, toItem: imageOptionView, attribute: .Bottom, multiplier: 1.0, constant: 1.0)
        imageOptionButton.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activateConstraints([topOptionButton, leadingOptionButton, trailingOptionButton, bottomOptionButton])
        
        
        return imageOptionView
    }

    
    func addComposeTextView(composeView: UIView, topView: UIView) {
        composeTopBorder.backgroundColor = UIColor.darkGrayColor()
        composeView.addSubview(composeTopBorder)
        
        composeTopBorderDefaultTop = NSLayoutConstraint(item: composeTopBorder, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        composeTopBorderKeyboardTop = NSLayoutConstraint(item: composeTopBorder, attribute: .Top, relatedBy: .Equal, toItem: toLabel, attribute: .Bottom, multiplier: 1.0, constant: 10.0)
        let leadingBorder = NSLayoutConstraint(item: composeTopBorder, attribute: .Leading, relatedBy: .Equal, toItem: composeView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingBorder = NSLayoutConstraint(item: composeTopBorder, attribute: .Trailing, relatedBy: .Equal, toItem: composeView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let borderHeight = NSLayoutConstraint(item: composeTopBorder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 3.0)
        
        composeTopBorderDefaultTop.priority = 999
        composeTopBorderKeyboardTop.priority = 251
        
        composeTopBorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([composeTopBorderDefaultTop, composeTopBorderKeyboardTop, leadingBorder, trailingBorder, borderHeight])
        
        if textEntered != nil {
            composeTextView.text = textEntered
        }
        composeTextView.font = UIFont(name: "OpenSans-Light", size: 17.0)
        composeTextView.textColor = slowpostBlack
        composeView.addSubview(composeTextView)
        
        let topCompose = NSLayoutConstraint(item: composeTextView, attribute: .Top, relatedBy: .Equal, toItem: composeTopBorder, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let leadingCompose = NSLayoutConstraint(item: composeTextView, attribute: .Leading, relatedBy: .Equal, toItem: composeView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingCompose = NSLayoutConstraint(item: composeTextView, attribute: .Trailing, relatedBy: .Equal, toItem: composeView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let bottomCompose = NSLayoutConstraint(item: composeTextView, attribute: .Bottom, relatedBy: .Equal, toItem: composeView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        composeTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([topCompose, leadingCompose, trailingCompose, bottomCompose])
        
        composeTextView.addSubview(placeholderText)
        placeholderText.text = "Compose your message"
        placeholderText.font = UIFont(name: "OpenSans-Italic", size: 15.0)
        placeholderText.textColor = slowpostLightGrey
        
        let topPlaceholder = NSLayoutConstraint(item: placeholderText, attribute: .Top, relatedBy: .Equal, toItem: composeTextView, attribute: .Top, multiplier: 1.0, constant: 10.0)
        let leadingPlaceholder = NSLayoutConstraint(item: placeholderText, attribute: .Leading, relatedBy: .Equal, toItem: composeTextView, attribute: .Leading, multiplier: 1.0, constant: 10.0)
        let placeholderHeight = NSLayoutConstraint(item: placeholderText, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 21)
        placeholderText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([topPlaceholder, leadingPlaceholder, placeholderHeight])

    }
    
    // Modifying view when keyboard is shown
    
    func keyboardShow(notification: NSNotification) {
        composeTopBorderDefaultTop.priority = 251
        composeTopBorderKeyboardTop.priority = 999
        updateViewConstraints()
        
        let userInfo = notification.userInfo!
        var r = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = composeTextView.convertRect(r, fromView:nil)
        composeTextView.contentInset.bottom = r.size.height + 60.0
        composeTextView.scrollIndicatorInsets.bottom = r.size.height + 60.0
        
        placeholderText.hidden = true
    }
    
    func keyboardHide(notification:NSNotification) {
        composeTopBorderDefaultTop.priority = 999
        composeTopBorderKeyboardTop.priority = 251
        updateViewConstraints()
        doneEditingButton.hidden = true
        validateSendAndPlaceholder()
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
    
    func validateSendAndPlaceholder() {
        if composeTextView.text != nil && composeTextView.text != "" {
            sendButtonView.hidden = false
            view.bringSubviewToFront(sendButtonView)
            placeholderText.hidden = true
            
            // This isn't working...
            defaultComposeViewBottom.constant = 60
//            sendComposeViewBottom.priority = 999
            updateViewConstraints()
        }
        else {
            sendButtonView.hidden = true
            placeholderText.hidden = false
            
            // This isn't working...
            defaultComposeViewBottom.constant = 0
//            sendComposeViewBottom.priority = 251
            updateViewConstraints()
        }
    }
    
    // Scheduling delivery
    
    func scheduleDelivery() {
        performSegueWithIdentifier("scheduleDelivery", sender: nil)
    }
    
    @IBAction func standardDeliveryChosen(segue: UIStoryboardSegue) {
            shadedView.hidden = true
            formatSendButton()
    }
    
    @IBAction func scheduledDeliveryChosen(segue: UIStoryboardSegue) {
            shadedView.hidden = true
            formatSendButton()
    }
    
    @IBAction func scheduleDeliveryCancelled(segue: UIStoryboardSegue) {
            shadedView.hidden = true
    }
    
    func formatSendButton() {
        if scheduledToArrive != nil {
            let dateString = scheduledToArrive!.formattedAsString("yyyy-MM-dd")
            sendButtonLabel.text = "Send (arrives on \(dateString)) >>"
        }
        else {
            sendButtonLabel.text = "Send right now >>"
        }
    }
    
    //
    
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sendMail" {
            let sendingViewController = segue.destinationViewController as? SendingViewController
            sendingViewController!.toPeople = toPeople
            sendingViewController!.toSearchPeople = toSearchPeople
            sendingViewController!.toEmails = toEmails
            sendingViewController!.content = composeTextView.text
            
            if imageSelected != nil {
                sendingViewController!.image = imageSelected
            }
            if scheduledToArrive != nil {
                sendingViewController!.scheduledToArrive = scheduledToArrive!
            }
        }
        else if segue.identifier == "scheduleDelivery" {
            view.bringSubviewToFront(shadedView)
            shadedView.hidden = false
        }
    }
    
    @IBAction func mailFailedToSend(segue: UIStoryboardSegue) {
    }
    
    @IBAction func notReadyToSend(segue: UIStoryboardSegue) {
    }

}
