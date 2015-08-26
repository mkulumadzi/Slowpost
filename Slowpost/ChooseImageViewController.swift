//
//  ChooseCardViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChooseImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    var toPerson:Person!
    var newMedia: Bool?
    var imageSelected:UIImageView!
    var imageSize = CGSizeMake(0,0)

    @IBOutlet weak var cropLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imageLibraryButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var cardGalleryButton: UIButton!
    @IBOutlet weak var removePhotoButton: TextUIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var nextButton: TextUIButton!
    
    override func viewDidLoad() {
        Flurry.logEvent("Choose_Image_View_Opened")
        
        super.viewDidLoad()
        
        toLabel.text = toPerson.name
        
        removePhotoButton.layer.cornerRadius = 5
        nextButton.layer.cornerRadius = 5
        validateButtons()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        imageScrollView.delegate = self
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false

    }
    
    override func viewDidAppear(animated: Bool) {
        validateButtons()
    }
    
    func setupSubview(image: UIImage) {
        let subViews = self.imageScrollView.subviews
        for subview in subViews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        imageSelected = UIImageView(image: image)
        imageSize = imageSelected.frame.size
        imageScrollView.addSubview(imageSelected)
    }
    
    override func viewDidLayoutSubviews() {
        imageScrollView.maximumZoomScale = 5.0
        imageScrollView.contentSize = imageSize
        let widthScale = imageScrollView.bounds.size.width / imageSize.width
        let heightScale = imageScrollView.bounds.size.height / imageSize.height
        imageScrollView.minimumZoomScale = widthScale
        imageScrollView.setZoomScale(max(widthScale, heightScale), animated: true )
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageSelected
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectPhotoFromLibrary(sender: AnyObject) {
        Flurry.logEvent("Chose_To_Select_Photo_From_Library")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
                
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as NSString]
            imagePicker.allowsEditing = false
            
            imagePicker.navigationBar.tintColor = UIColor.whiteColor()
            imagePicker.navigationBar.barTintColor = UIColor(red: 0/255, green: 182/255, blue: 185/255, alpha: 1.0)
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            newMedia = false
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        Flurry.logEvent("Chose_To_Take_Picture")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                
                let imagePicker = UIImagePickerController()

                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                newMedia = true
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == (kUTTypeImage as! String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            Flurry.logEvent("Got_Image_From_Library_Or_Camera")
            self.setupSubview(image)
            
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            } else if mediaType == (kUTTypeMovie as! String) {
                // Code to support video here
            }
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func cropImage() -> UIImage {
        var scale = 1 / imageScrollView.zoomScale
        
        var contextImage:UIImage = UIImage(CGImage: imageSelected.image!.CGImage, scale: 1, orientation: imageSelected.image!.imageOrientation)!
        
        var visibleRect:CGRect!
        let xOffset = imageScrollView.contentOffset.x * scale
        let yOffset = imageScrollView.contentOffset.y * scale
        let rectWidth = imageScrollView.bounds.size.width * scale
        let rectHeight = imageScrollView.bounds.size.height * scale
        let totalWidth = contextImage.size.width
        let totalHeight = contextImage.size.height
        
        switch contextImage.imageOrientation.hashValue {
        case 0:
            visibleRect = CGRectMake(xOffset, yOffset, rectWidth, rectHeight)
        case 1:
            visibleRect = CGRectMake(totalWidth - rectWidth - xOffset, totalHeight - rectHeight - yOffset, rectWidth, rectHeight)
        case 2:
            visibleRect = CGRectMake(totalHeight - rectHeight - yOffset, xOffset, rectHeight, rectWidth)
        case 3:
            visibleRect = CGRectMake(yOffset, totalWidth - rectWidth - xOffset, rectHeight, rectWidth)
        default:
            visibleRect = CGRectMake(imageScrollView.contentOffset.x * scale, imageScrollView.contentOffset.y*scale, imageScrollView.bounds.size.width*scale, imageScrollView.bounds.size.height*scale)
        }
        
        var ref:CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, visibleRect)
        
        var croppedImage:UIImage = UIImage(CGImage: ref, scale: scale, orientation: contextImage.imageOrientation)!
        
        return croppedImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func removePhoto(sender: AnyObject) {
        let subViews = self.imageScrollView.subviews
        for subview in subViews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        imageSelected = nil
        validateButtons()
    }
    
    func validateButtons() {
        if imageSelected != nil {
            imageAdded()
        }
        else {
            noImage()
        }
    }
    
    func imageAdded() {
        imageLibraryButton.hidden = true
        libraryLabel.hidden = true
        takePhotoButton.hidden = true
        cameraLabel.hidden = true
        cardGalleryButton.hidden = true
        galleryLabel.hidden = true
        
        cropLabel.hidden = false
        removePhotoButton.hidden = false
        nextButton.hidden = false
    }
    
    func noImage() {
        imageLibraryButton.hidden = false
        libraryLabel.hidden = false
        takePhotoButton.hidden = false
        cameraLabel.hidden = false
        cardGalleryButton.hidden = false
        galleryLabel.hidden = false
        
        cropLabel.hidden = true
        removePhotoButton.hidden = true
        nextButton.hidden = true
    }
    
    @IBAction func backToSelectRecipient(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func cancelToChooseImage(segue:UIStoryboardSegue) {
        Flurry.logEvent("Canceled_And_Back_to_Choose_Image")
    }
    
    @IBAction func cardGalleryImageSelected(segue:UIStoryboardSegue) {
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("composeMessage", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeMessage" {
            let composeMailViewController = segue.destinationViewController as? ComposeMailViewController
            if imageSelected != nil {
                let croppedImage = self.cropImage()
                composeMailViewController?.cardImage = croppedImage
            }
            else {
                composeMailViewController?.cardImage = UIImage(named: "Default Card.png")
            }
            composeMailViewController!.toPerson = toPerson
        }
    }

}
