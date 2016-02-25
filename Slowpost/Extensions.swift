//
//  Extensions.swift
//  Slowpost
//
//  Created by Evan Waters on 6/22/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import Foundation
import UIKit

extension NSDate {
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
    
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        var isGreater = false
        if compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        var isLess = false
        if compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        return isLess
    }
    
    func addDays(daysToAdd : Int) -> NSDate {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = dateByAddingTimeInterval(secondsInDays)
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = dateByAddingTimeInterval(secondsInHours)
        return dateWithHoursAdded
    }
    
    func formattedAsString(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    
    func formattedAsUTCString() -> String {
        let format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        return formattedAsString(format)
    }
}

extension Array {
    var last: Element {
        return self[endIndex - 1]
    }
}

extension UIImage {
    public func resize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            let newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.5)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData!)
            })
        })
    }
}

extension UITextView {
    public func addTopBorder() {
        let border = CALayer()
        let thickness = CGFloat(2.0)
        border.borderColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: thickness)
        
        border.borderWidth = thickness
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
    
    public func addBottomBorder() {
        let border = CALayer()
        let thickness = CGFloat(1.0)
        border.borderColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: frame.size.height, width:  frame.size.width, height: thickness)
        
        border.borderWidth = thickness
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
    
}

private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
    /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
    /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
    /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone 6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
    /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
    /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
    /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
    /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
    /* iPad Air 2 */      "iPad5,1": "iPad Air 2", "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
    /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad Mini", "iPad4,5": "iPad Mini", "iPad4,6": "iPad Mini",
    /* iPad Mini 3 */     "iPad4,7": "iPad Mini", "iPad4,8": "iPad Mini", "iPad4,9": "iPad Mini",
    /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
         for child in mirror.children where child.value as? Int8 != 0 {
             identifier.append(UnicodeScalar(UInt8(child.value as! Int8)))
         }
        
        return DeviceList[identifier] ?? identifier
    }
    
}

extension UIButton {
    
    class func textButton(backgroundColor: UIColor, title: String, textColor: UIColor, target: AnyObject, action: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = backgroundColor
        button.setTitle(title, forState: .Normal)
        if let titleLabel = button.titleLabel {
            titleLabel.textColor = textColor
            titleLabel.font = UIFont.buttonFont()
        }
        button.addTarget(target, action: Selector(action), forControlEvents: .TouchUpInside)
        return button
    }
    
    class func standardTextButton(title: String, target: AnyObject, action: String) -> UIButton {
        let button = UIButton.textButton(slowpostDarkGreen, title: title, textColor: UIColor.whiteColor(), target: target, action: action)
        return button
    }
    
}

extension UIFont {
    
    class func buttonFont() -> UIFont {
        if let font = UIFont(name: "OpenSans-Semibold", size: 15.0) {
            return font
        }
        else {
            return UIFont.boldSystemFontOfSize(15.0)
        }
    }
    
    class func italicFont() -> UIFont {
        if let font = UIFont(name: "OpenSans-Italic", size: 15.0) {
            return font
        }
        else {
            return UIFont.italicSystemFontOfSize(15.0)
        }
    }
    
}

extension UIView {
    
    func newSubview(backgroundColor: UIColor, cornerRadius: CGFloat?) -> UIView {
        let view = UIView()
        view.backgroundColor = backgroundColor
        if let cornerRadius = cornerRadius {
            view.layer.cornerRadius = cornerRadius
        }
        addSubview(view)
        return view
    }
    
    func newLabel(font: UIFont, textColor: UIColor, text: String?, alignment: NSTextAlignment?, backgroundColor: UIColor?) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        if let text = text { label.text = text }
        if let alignment = alignment { label.textAlignment = alignment }
        if let backgroundColor = backgroundColor { label.backgroundColor = backgroundColor }
        addSubview(label)
        return label
    }
    
}