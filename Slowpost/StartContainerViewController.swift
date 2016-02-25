//
//  StartContainerViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 2/25/16.
//  Copyright © 2016 Evan Waters. All rights reserved.
//

import UIKit

class StartContainerViewController: UIViewController {
    
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var slowpostText: UILabel!
    @IBOutlet weak var slowpostIcon: UIImageView!
    @IBOutlet weak var logoLabelCenterY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    // MARK: Setup
    
    private func configure() {
    }
    
    override func viewDidAppear(animated: Bool) {
        startAnimation()
        scaleFontAnimation()
    }
    
    private func startAnimation() {
        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: [], animations: {
            self.welcomeText.alpha = 0.0
            self.slowpostIcon.alpha = 0.0
            }, completion: { (values: Bool) in
                
        })
        
        logoLabelCenterY.constant = (view.frame.height / 2) - 30
        UIView.animateKeyframesWithDuration(1.0, delay: 1.0, options: [], animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
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

}
