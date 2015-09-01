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
    
    var pageOne:UIViewController!
    var pageTwo:UIViewController!
    var pageThree:UIViewController!
    var pageFour:UIViewController!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.logEvent("Welcome_Screen_Displayed")
        
        pageOne = self.storyboard!.instantiateViewControllerWithIdentifier("pageOne") as! UIViewController
        pageTwo = self.storyboard!.instantiateViewControllerWithIdentifier("pageTwo") as! UIViewController
        pageThree = self.storyboard!.instantiateViewControllerWithIdentifier("pageThree") as! UIViewController
        pageFour = self.storyboard!.instantiateViewControllerWithIdentifier("pageFour") as! UIViewController

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
        pageController.delegate = self
        
        let startingViewControllers: NSArray = [pageOne]
        pageController.setViewControllers(startingViewControllers as! [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
        self.view.bringSubviewToFront(logInButton)
        self.view.bringSubviewToFront(signUpButton)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 122/255, alpha: 1.0)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        Flurry.logEvent("Page_View_Finished_Animating")
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if viewController.restorationIdentifier == "pageOne" {
            return nil
        } else if viewController.restorationIdentifier == "pageTwo" {
            return pageOne
        } else if viewController.restorationIdentifier == "pageThree" {
            return pageTwo
        } else if viewController.restorationIdentifier == "pageFour" {
            return pageThree
        } else {
            return nil
        }

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if viewController.restorationIdentifier == "pageOne" {
            return pageTwo
        } else if viewController.restorationIdentifier == "pageTwo" {
            return pageThree
        } else if viewController.restorationIdentifier == "pageThree" {
            return pageFour
        } else if viewController.restorationIdentifier == "pageFour" {
            return nil
        } else {
            return nil
        }
        
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
