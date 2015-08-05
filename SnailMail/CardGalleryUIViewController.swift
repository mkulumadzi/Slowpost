//
//  CardGalleryUIViewController.swift
//  Snailtale
//
//  Created by Evan Waters on 7/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class CardGalleryUIViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //To Do: Make an image server and do away with this hard coding stuff
    var photoNames = ["SnailMail at the Beach.png", "Sevilla.jpg", "Default Card.png", "Fig Arch.jpg", "SnailMail Closeup.png", "Fireworks.jpg", "Parachute.png", "Kili Sunrise.jpg", "Ooh.jpg", "Smiles.jpg", "Glacier.jpg", "Ice.jpg", "Prairie.jpg", "Reflection.jpg", "Salamander.jpg", "Signs.jpg"]
    
    var photoArray = [UIImage]()
    var imageSelected:UIImage!
    var imageSelectedName:String!
    
    @IBOutlet weak var cardCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populatePhotoArray()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func populatePhotoArray() {
        
        for name in photoNames {
            self.photoArray.append(UIImage(named: name)!)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        
        var width:CGFloat = self.cardCollection.frame.width - 20
        var height:CGFloat = width * 3 / 4
        
        var cardSize = CGSize.init(width: width, height: height)
        
        return cardSize
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardCell", forIndexPath: indexPath) as! CardCollectionViewCell
        
        let image = photoArray[indexPath.row] as UIImage
        
        cell.cardImage.image = image
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        imageSelected = UIImage(named: photoNames[indexPath.row])
        imageSelectedName = photoNames[indexPath.row]
        self.performSegueWithIdentifier("imageSelected", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "imageSelected" {
            let chooseImageViewController = segue.destinationViewController as? ChooseImageViewController
            chooseImageViewController!.setupSubview(imageSelected)
        }
    }
    
    

}
