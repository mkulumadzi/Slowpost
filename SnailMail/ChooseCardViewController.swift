//
//  ChooseCardViewController.swift
//  SnailMail
//
//  Created by Evan Waters on 6/16/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit

class ChooseCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //To Do: Make an image server and do away with this hard coding stuff
    var photoNames = ["SnailMail at the Beach.png", "Sevilla.jpg", "Default Card.png", "Fig Arch.jpg", "SnailMail Closeup.png", "Fireworks.jpg", "Parachute.png", "Kili Sunrise.jpg", "Ooh.jpg", "Smiles.jpg", "Glacier.jpg", "Ice.jpg", "Prairie.jpg", "Reflection.jpg", "Salamander.jpg", "Signs.jpg"]
    
    var photoArray = [UIImage]()
    var imageName:String!
    var toUsername:String!

    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var cardCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toLabel.text = toUsername
        populatePhotoArray()

        // Do any additional setup after loading the view.
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
        
        let imageSelected = photoNames[indexPath.row]
        imageName = imageSelected
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeMessage" {
            let composeMailViewController = segue.destinationViewController as? ComposeMailViewController
            if let name = imageName {
                composeMailViewController?.imageName = name
            }
            if let to = toUsername {
                composeMailViewController!.toUsername = to
            }
        }
    }
    
    @IBAction func backToSelectRecipient(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

}
