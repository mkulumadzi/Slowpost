//
//  CardGalleryUIViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Photos

class CardGalleryUIViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate {
    
    var cardNames:[String]!
    
    var galleryPhotos = [UIImage]()
    var cameraRollPhotos = [UIImage]()
    
    var fetchResult:PHFetchResult!
    
    var imageSelected:UIImage!
    var imageSelectedName:String!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var cardCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Opened_Card_Gallery")
        segmentedControl.addTarget(self, action:"toggleResults", forControlEvents: .ValueChanged)
        
        activityIndicator.startAnimating()
        getCards()
        getImagesFromCameraRoll()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func getImagesFromCameraRoll() {
        
        let maxDimension = (cardCollection.frame.width - 30) / 2
        let targetSize: CGSize = CGSize(width: maxDimension, height: maxDimension)
        let contentMode: PHImageContentMode = .AspectFit
        let fetchOptions:PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 200
        fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
        
        // photoAsset is an object of type PHFetchResult
        fetchResult.enumerateObjectsUsingBlock {
            object, index, stop in
            
            let options = PHImageRequestOptions()
            options.synchronous = true
            options.deliveryMode = .HighQualityFormat
            
            PHImageManager.defaultManager().requestImageForAsset(object as! PHAsset, targetSize: targetSize, contentMode: contentMode, options: options) {
                image, info in
                self.cameraRollPhotos.append(image!)
            }
        }
        
        
    
    }
    
    func toggleResults() {
        cardCollection.reloadData()
    }
    
    func getCards() {
        let cardsURL = "\(PostOfficeURL)cards"
        
        RestService.getRequest(cardsURL, headers: nil, completion: { (error, result) -> Void in
            if error != nil {
                print(error)
            }
            else {
                if let cardArray = result as? [String] {
                    self.cardNames = cardArray
                    self.populatePhotoArray()
                }
                else {
                    print("Unexpected JSON result getting cards")
                }
            }
        })
    }
    
    
    func populatePhotoArray() {
        
        for card in cardNames {
            let newCardName = card.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            let imageURL = "\(PostOfficeURL)/image/\(newCardName)"
            FileService.downloadImage(imageURL, completion: { (error, result) -> Void in
                if error != nil {
                    print(error)
                }
                else if let image = result as? UIImage {
                    if self.activityIndicator.isAnimating() {
                        self.activityIndicator.stopAnimating()
                    }
                    self.galleryPhotos.append(image)
                    self.cardCollection.reloadData()
                }
            })
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return cameraRollPhotos.count
        default:
            return galleryPhotos.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        
        let maxDimension = (cardCollection.frame.width - 30) / 2
        var image:UIImage!
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            image = cameraRollPhotos[indexPath.row]
        default:
            image = galleryPhotos[indexPath.row]
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardCell", forIndexPath: indexPath) as! CardCollectionViewCell
        
        var image:UIImage!
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            image = cameraRollPhotos[indexPath.row]
        default:
            image = galleryPhotos[indexPath.row]
        }
        
        cell.cardImage.image = image
        
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
            image = galleryPhotos[indexPath.row]
            let parameters:[String: String] = ["Name": cardNames[indexPath.row]]
            Flurry.logEvent("Chose_Image_From_Gallery", withParameters: parameters)
        }
        
        imageSelected = image
        performSegueWithIdentifier("imageSelected", sender: nil)
    }
    
    func getFullSizePhoto(index: Int) -> UIImage {
        var imageSelected:UIImage!
        let object = fetchResult.objectAtIndex(index)
        let targetSize: CGSize = CGSize(width: 800.0, height: 800.0)
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.deliveryMode = .HighQualityFormat
        PHImageManager.defaultManager().requestImageForAsset(object as! PHAsset, targetSize: targetSize, contentMode: .AspectFit, options: options) {
            image, info in
            imageSelected = image
        }
        return imageSelected
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "imageSelected" {
//            Flurry.logEvent("Chose_Image_From_Gallery")
            let chooseImageViewController = segue.destinationViewController as? ChooseImageViewController
            chooseImageViewController!.imageView.image = imageSelected
        }
    }
    
    

}
