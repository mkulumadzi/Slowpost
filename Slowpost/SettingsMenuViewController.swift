//
//  SettingsMenuViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/24/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData

class SettingsMenuViewController: BaseViewController {
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var editPasswordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Settings_opened")
        configure()
    }
    
    //MARK: Setup
    
    private func configure() {
        logOutButton.layer.cornerRadius = 5
        editProfileButton.layer.cornerRadius = 5
        editPasswordButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5

    }

}
