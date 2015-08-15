//
//  CardGalleryUIViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class CardGalleryUIViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var cardNames:[String]!
    
    var photoArray = [UIImage]()
    var imageSelected:UIImage!
    var imageSelectedName:String!
    
    @IBOutlet weak var cardCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Opened_Card_Gallery")
        
        activityIndicator.startAnimating()
        getCards()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func getCards() {
        let cardsURL = "\(PostOfficeURL)cards"
        
        RestService.getRequest(cardsURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                println(error)
            }
            else if let jsonResult = result as? Array<String> {
                self.cardNames = jsonResult
                self.populatePhotoArray()
            }
            else {
                println("Unexpected JSON result getting cards")
            }
        })
    }
    
    
    func populatePhotoArray() {
        
        for card in cardNames {
            let newCardName = card.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            let imageURL = "\(PostOfficeURL)/image/\(newCardName)"
            FileService.downloadImage(imageURL, completion: { (error, result) -> Void in
                if error != nil {
                    println(error)
                }
                else if let image = result as? UIImage {
                    if self.activityIndicator.isAnimating() {
                        self.activityIndicator.stopAnimating()
                    }
                    self.photoArray.append(image)
                    self.cardCollection.reloadData()
                }
            })
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
        imageSelected = photoArray[indexPath.row]
        self.performSegueWithIdentifier("imageSelected", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "imageSelected" {
            Flurry.logEvent("Chose_Image_From_Gallery")
            let chooseImageViewController = segue.destinationViewController as? ChooseImageViewController
            chooseImageViewController!.setupSubview(imageSelected)
        }
    }
    
    

}
