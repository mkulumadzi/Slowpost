//
//  WelcomeScreenViewController.swift
//  Slowpost
//
//  Created by Evan Waters on 7/23/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import Foundation

class WelcomeScreenViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var pageViewController: UIPageViewController?
    var pageIndex:Int = 0
    private let titleArray = ["One", "Two", "Three", "Four"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createPageViewController()
        setupPageControl()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createPageViewController() {
        
        let pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageController.dataSource = self
//        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("pageViewController") as! UIPageViewController
//        pageController.dataSource = self
        pageController.delegate = self
        
        if titleArray.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as! [WelcomePageItemViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
        self.view.bringSubviewToFront(logInButton)
        self.view.bringSubviewToFront(signUpButton)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
//        appearance.pageIndicatorTintColor = UIColor.grayColor()
//        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! WelcomePageItemViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! WelcomePageItemViewController
        
        if itemController.itemIndex+1 < titleArray.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> WelcomePageItemViewController? {
        
        if itemIndex < titleArray.count {
//            let welcomePageItemViewController = WelcomePageItemViewController.new()
            let welcomePageItemViewController = self.storyboard!.instantiateViewControllerWithIdentifier("pageItemController") as! WelcomePageItemViewController
            welcomePageItemViewController.itemIndex = itemIndex
            welcomePageItemViewController.labelValue = titleArray[itemIndex]
            return welcomePageItemViewController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return titleArray.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
