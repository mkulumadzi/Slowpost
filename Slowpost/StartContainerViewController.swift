//
//  StartContainerViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 2/25/16.
//  Copyright © 2016 Evan Waters. All rights reserved.
//

import UIKit

class StartContainerViewController: UIViewController {
    
    var embeddedViewController: UIViewController!
    
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var slowpostText: UILabel!
    @IBOutlet weak var slowpostIcon: UIImageView!
    @IBOutlet weak var logoLabelCenterY: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    // MARK: Setup
    
    private func configure() {
    }
    
    override func viewDidAppear(animated: Bool) {
        startAnimation()
    }
    
    private func startAnimation() {
        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: [], animations: {
            self.welcomeText.alpha = 0.0
            self.slowpostIcon.alpha = 0.0
            }, completion: {(values: Bool) in
                self.scaleFontAnimation()
        })
        
        logoLabelCenterY.constant = (view.frame.height / 2) - 30
        UIView.animateKeyframesWithDuration(1.0, delay: 1.0, options: [], animations: {
            self.view.layoutIfNeeded()
            }, completion: {(values: Bool) in
                self.showEmailEntryController()
        })
    }
    
    private func scaleFontAnimation() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(CATransform3D: CATransform3DMakeScale(1,1,1)), NSValue(CATransform3D: CATransform3DMakeScale(0.375,0.375,0.375))]
        scaleAnimation.duration = 1.0
        scaleAnimation.fillMode = kCAFillModeForwards
        scaleAnimation.removedOnCompletion = false
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        slowpostText.layer.addAnimation(scaleAnimation, forKey: "transform")
    }
    
    private func showEmailEntryController() {
        containerView.alpha = 0.0
        embeddedViewController = fetchViewControllerFromStoryboard("login", storyboardIdentifier: "emailEntry") as! EmailEntryViewController
        embedViewController(embeddedViewController, intoView: containerView)
        UIView.animateWithDuration(1.0, animations: {
            self.containerView.alpha = 1.0
        })
    }
    
    // MARK: Segues
    
    @IBAction func emailEntered(segue: UIStoryboardSegue) {
        removeEmbeddedViewController(embeddedViewController)
    }

}

struct LoginPerson {
    var email:String!
    var givenName:String!
    var fullName:String!
    var username:String!
    var password:String!
}
