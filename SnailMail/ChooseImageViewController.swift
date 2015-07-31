//
//  ChooseCardViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ChooseImageViewController: UIViewController {
    
    var cardImage:UIImage!
    var imageName:String!
    var toPerson:Person!

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
        
        if cardImage != nil {
            imageSelected.image = cardImage
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeMessage" {
            let composeMailViewController = segue.destinationViewController as? ComposeMailViewController
            if cardImage != nil {
                composeMailViewController?.cardImage = self.cardImage
                if imageName != nil {
                    composeMailViewController?.imageName = self.imageName
                }
            }
            composeMailViewController!.toPerson = toPerson
        }
    }
    
    @IBAction func backToSelectRecipient(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func cancelToChooseImage(segue:UIStoryboardSegue) {
    }
    
    @IBAction func imageSelected(segue:UIStoryboardSegue) {
    }

}
