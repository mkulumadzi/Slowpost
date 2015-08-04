//
//  ChooseCardViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChooseImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    var imageName:String!
    var toPerson:Person!
    var newMedia: Bool?
    var imageSelected:UIImageView!
    var imageSize = CGSizeMake(0,0)

    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imageLibraryButton: SnailMailTextUIButton!
    @IBOutlet weak var takePhotoButton: SnailMailTextUIButton!
    @IBOutlet weak var cardGalleryButton: SnailMailTextUIButton!
    @IBOutlet weak var removePhotoButton: SnailMailTextUIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toLabel.text = toPerson.name
        
        imageLibraryButton.layer.cornerRadius = 5
        takePhotoButton.layer.cornerRadius = 5
        cardGalleryButton.layer.cornerRadius = 5
        
        imageScrollView.delegate = self
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false

    }
    
    func setupSubview(image: UIImage) {
        let subViews = self.imageScrollView.subviews
        for subview in subViews {
            if subview is UIImageView {
                println("Removing subview")
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
                
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as NSString]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
            newMedia = false
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
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
        imageSelected.image = nil
        removePhotoButton.hidden = true
    }
    
    @IBAction func backToSelectRecipient(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func cancelToChooseImage(segue:UIStoryboardSegue) {
    }
    
    @IBAction func imageSelected(segue:UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeMessage" {
            let composeMailViewController = segue.destinationViewController as? ComposeMailViewController
            if imageSelected.image != nil {
                let croppedImage = self.cropImage()
                composeMailViewController?.cardImage = croppedImage
                if imageName != nil {
                    composeMailViewController?.imageName = self.imageName
                }
            }
            composeMailViewController!.toPerson = toPerson
        }
    }

}
