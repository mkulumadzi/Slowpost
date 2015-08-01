//
//  ChooseCardViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import MobileCoreServices

class ChooseImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageName:String!
    var toPerson:Person!
    var newMedia: Bool?

    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var imageLibraryButton: SnailMailTextUIButton!
    @IBOutlet weak var takePhotoButton: SnailMailTextUIButton!
    @IBOutlet weak var cardGalleryButton: SnailMailTextUIButton!
    @IBOutlet weak var removePhotoButton: SnailMailTextUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toLabel.text = toPerson.name
        
        imageLibraryButton.layer.cornerRadius = 5
        takePhotoButton.layer.cornerRadius = 5
        cardGalleryButton.layer.cornerRadius = 5
        
        if imageSelected.image == nil {
            removePhotoButton.hidden = true
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        if imageSelected.image == nil {
            removePhotoButton.hidden = true
        }
        else {
           removePhotoButton.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeMessage" {
            let composeMailViewController = segue.destinationViewController as? ComposeMailViewController
            if imageSelected.image != nil {
                composeMailViewController?.cardImage = self.imageSelected.image
                if imageName != nil {
                    composeMailViewController?.imageName = self.imageName
                }
            }
            composeMailViewController!.toPerson = toPerson
        }
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
            
            imageSelected.image = image
            
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

}
