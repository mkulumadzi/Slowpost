//
//  ViewControllerExtensions.swift
//  Slowpost
//
//  Created by Evan Waters on 2/23/16.
//  Copyright © 2016 Evan Waters. All rights reserved.
//

import Foundation

extension UIViewController {
    
    //MARK: Embedding view controllers
    
    func fillSubview(subview : UIView, inSuperView superview : UIView) {
        let views : [ String : AnyObject ] = ["subview" : subview]
        let options = NSLayoutFormatOptions(rawValue: 0)
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: options, metrics: nil, views: views))
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: options, metrics: nil, views: views))
    }
    
    func embedViewController(vc : UIViewController, intoView superview : UIView) {
        self.embedViewController(vc, intoView: superview, placementBlock: nil)
    }
    
    func embedViewController(vc : UIViewController, intoView superview : UIView, placementBlock : ((UIView) -> Void)?) {
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(vc)
        superview.addSubview(vc.view)
        
        if let placementBlock = placementBlock {
            placementBlock(vc.view)
        }
        else {
            self.fillSubview(vc.view, inSuperView: view)
        }
        
        vc.didMoveToParentViewController(self)
    }
    
    func removeEmbeddedViewController(vc : UIViewController) {
        vc.willMoveToParentViewController(self)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    func fetchViewControllerFromStoryboard(storyboardName: String, storyboardIdentifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(storyboardIdentifier)
        return vc
    }
    
    
    //MARK: Warning and Message Labels
    
    func initializeWarningLabel() -> UILabel {
        let warningLabel = initializeHeaderLabel()
        warningLabel.backgroundColor = slowpostBlack
        return warningLabel
    }
    
    func initializeMessageLabel() -> UILabel {
        let messageLabel = initializeHeaderLabel()
        messageLabel.backgroundColor = slowpostDarkGrey
        return messageLabel
    }
    
    func initializeHeaderLabel() -> UILabel {
        let headerLabel = UILabel()
        view.addSubview(headerLabel)
        headerLabel.backgroundColor = slowpostBlack
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.font = UIFont(name: "OpenSans", size: 15.0)
        headerLabel.textAlignment = .Center
        pinItemToTopWithHeight(headerLabel, toItem: view, height: 30.0)
        headerLabel.alpha = 0.0
        return headerLabel
    }
    
    
    func showLabelWithMessage(label: UILabel, message: String) {
        label.text = message
        UIView.animateWithDuration(0.5, animations: {
            label.alpha = 1.0
        })
    }
    
    func hideItem(item: UIView) {
        UIView.animateWithDuration(0.5, animations: {
            item.alpha = 0.0
        })
    }
    
    //MARK: Autolayout helpers
    
    func activateConstraintsForItem(item: UIView, constraints: [NSLayoutConstraint]) {
        item.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func pinItemToTopWithHeight(item: UIView, toItem: UIView, height: CGFloat) {
        let leading = NSLayoutConstraint.leading(item, toItem: toItem, constant: 0.0)
        let trailing = NSLayoutConstraint.trailing(item, toItem: toItem, constant: 0.0)
        let top = NSLayoutConstraint.top(item, toItem: toItem, constant: 0.0)
        let height = NSLayoutConstraint.height(item, height: height)
        activateConstraintsForItem(item, constraints: [leading, trailing, top, height])
    }
    
    func pinItemToBottomWithHeight(item: UIView, toItem: UIView, height: CGFloat) {
        let leading = NSLayoutConstraint.leading(item, toItem: toItem, constant: 0.0)
        let trailing = NSLayoutConstraint.trailing(item, toItem: toItem, constant: 0.0)
        let bottom = NSLayoutConstraint.bottom(item, toItem: toItem, constant: 0.0)
        let height = NSLayoutConstraint.height(item, height: height)
        activateConstraintsForItem(item, constraints: [leading, trailing, bottom, height])
    }
    
    func pinItemToBottomWithOptions(item: UIView, toItem: UIView, leading: CGFloat, trailing: CGFloat, bottom: CGFloat, height: CGFloat) {
        let leadingConstraint = NSLayoutConstraint.leading(item, toItem: toItem, constant: leading)
        let trailingConstraint = NSLayoutConstraint.trailing(item, toItem: toItem, constant: trailing)
        let bottomConstraint = NSLayoutConstraint.bottom(item, toItem: toItem, constant: bottom)
        let heightConstraint = NSLayoutConstraint.height(item, height: height)
        activateConstraintsForItem(item, constraints: [leadingConstraint, trailingConstraint, bottomConstraint, heightConstraint])
    }
    
    func pinItemToBottom(item: UIView, toItem: UIView) {
        let leading = NSLayoutConstraint.leading(item, toItem: toItem, constant: 0.0)
        let trailing = NSLayoutConstraint.trailing(item, toItem: toItem, constant: 0.0)
        let bottom = NSLayoutConstraint.bottom(item, toItem: toItem, constant: 0.0)
        activateConstraintsForItem(item, constraints: [leading, trailing, bottom])
    }
    
    func centerVerticallyPinTrailing(item: UIView, toItem: UIView, trailingConstant: CGFloat) {
        let centerVertically = NSLayoutConstraint.centerVertically(item, toItem: toItem)
        let trailing = NSLayoutConstraint.trailing(item, toItem: toItem, constant: -10.0)
        activateConstraintsForItem(item, constraints: [centerVertically, trailing])
    }
    
    func embedItem(item: UIView, toItem: UIView) {
        addConstraintsForItemInContainer(item, toItem: toItem, leadingConstant: 0.0, trailingConstant: 0.0, topConstant: 0.0, bottomConstant: 0.0)
    }
    
    func addConstraintsForItemInContainer(item: UIView, toItem: UIView, leadingConstant: CGFloat, trailingConstant: CGFloat, topConstant: CGFloat, bottomConstant: CGFloat) {
        let leading = NSLayoutConstraint.leading(item, toItem: toItem, constant: leadingConstant)
        let trailing = NSLayoutConstraint.trailing(item, toItem: toItem, constant: trailingConstant)
        let top = NSLayoutConstraint.top(item, toItem: toItem, constant: topConstant)
        let bottom = NSLayoutConstraint.bottom(item, toItem: toItem, constant: bottomConstant)
        activateConstraintsForItem(item, constraints: [leading, trailing, top, bottom])
    }
    
}

extension NSLayoutConstraint {
    
    class func height(item: UIView, height: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height)
    }
    
    class func leading(item: UIView, toItem: UIView, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .Leading, relatedBy: .Equal, toItem: toItem, attribute: .Leading, multiplier: 1.0, constant: constant)
    }
    
    class func trailing(item: UIView, toItem: UIView, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .Trailing, relatedBy: .Equal, toItem: toItem, attribute: .Trailing, multiplier: 1.0, constant: constant)
    }
    
    class func top(item: UIView, toItem: UIView, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .Top, relatedBy: .Equal, toItem: toItem, attribute: .Top, multiplier: 1.0, constant: constant)
    }
    
    class func bottom(item: UIView, toItem: UIView, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .Bottom, relatedBy: .Equal, toItem: toItem, attribute: .Bottom, multiplier: 1.0, constant: constant)
    }
    
    class func centerVertically(item: UIView, toItem: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .CenterY, relatedBy: .Equal, toItem: toItem, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
    }
    
    class func centerHorizontally(item: UIView, toItem: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .CenterX, relatedBy: .Equal, toItem: toItem, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    }
    
    class func trailingToLeading(item: UIView, toItem: UIView, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .Trailing, relatedBy: .Equal, toItem: toItem, attribute: .Leading, multiplier: 1.0, constant: constant)
    }
    
}