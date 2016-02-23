//
//  PhotoLibraryViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/31/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import MobileCoreServices

class PhotoLibraryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var newMedia: Bool?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


}
