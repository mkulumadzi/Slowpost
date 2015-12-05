    //
//  AppDelegate.swift
//  Slowpost
//
//  Created by Evan Waters on 3/11/15.
//  Copyright (c) 2015 Evan Waters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataController: DataController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        dataController = DataController()
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))
        
        application.registerForRemoteNotifications()
        
        //Manually set font for nav bar header (couldn't set in storyboard)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "OpenSans-Semibold", size: 17)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        Flurry.setCrashReportingEnabled(true)
        Flurry.startSession("FT74F5GW8XVG66BQBXW8")
        
        
        if launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
            Flurry.logEvent("Opened_App_From_Notification")
            print("Got a remote notification")
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let isFacebookURL = (url.scheme.hasPrefix("fb\(FBSDKSettings.appID())") && url.host == "authorize")
        if isFacebookURL {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let token = LoginService.getTokenFromKeychain()
        if token != nil {
            updateAppIconBadge(application)
        }

        Flurry.logEvent("Entered_Background")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        Flurry.logEvent("Became_Active")
        FBSDKAppEvents.activateApp()
        let notification = NSNotification(name: "appBecameActive:", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Flurry.logEvent("Application_Terminated")
        
        if dataController != nil {
            dataController.save()
        }

    }
    
    // MARK: Adding functions for notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token:NSData) {
        
        let tokenChars = UnsafePointer<CChar>(token.bytes)
        var tokenString = ""
        
        for var i = 0; i < token.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        deviceToken = tokenString
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationWithError error: NSError) {
        print("We couldn't register for remote notifications...")
        print("\(error), \(error.localizedDescription)")
    }
    
    
//    When a remote notification arrives, the system displays the notification to the user and launches the app in the background (if needed) so that it can call this method. Launching your app in the background gives you time to process the notification and download any data associated with it, minimizing the amount of time that elapses between the arrival of the notification and displaying that data to the user.
//    
//    As soon as you finish processing the notification, you must call the block in the handler parameter or your app will be terminated. Your app has up to 30 seconds of wall-clock time to process the notification and call the specified completion handler block. In practice, you should call the handler block as soon as you are done processing the notification. The system tracks the elapsed time, power usage, and data costs for your app’s background downloads. Apps that use significant amounts of power when processing remote notifications may not always be woken up early to process future notifications.
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void ) {
        
        Flurry.logEvent("Received remote notification")
        
//        if let type = userInfo["type"] as? NSString {
//            if type == "New Mail" {
//                print("New mail")
//            }
//            else if type == "Delivered Mail" {
//                print("Delivered mail")
//            }
//        }
        
        completionHandler(UIBackgroundFetchResult.NewData)
        
    }
  
//    The app calls this method when the user taps an action button in an alert displayed in response to a remote notification. Remote notifications that include a category key in their payload display buttons for the actions in the corresponding category. If the user taps one of those buttons, the system wakes up the app (launching it if needed) and calls this method in the background. Your implementation of this method should perform the action associated with the specified identifier and execute the block in the completionHandler parameter as soon as you are done. Failure to execute the completion handler block at the end of your implementation will cause your app to be terminated.
//    
//    To configure the actions for a given category, create a UIUserNotificationActionSettings object and register it with the app when you call the registerUserNotificationSettings: method.
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject: AnyObject], comletionHandler completionHandler: () -> Void ) {
        
    }
    

    //Refreshing app badge icon based on number of unread mail
    func updateAppIconBadge(application: UIApplication) {
        
        let fetchRequest = NSFetchRequest(entityName: "Mail")
        let userId = LoginService.getUserIdFromToken()
        let predicate1 = NSPredicate(format: "ANY toPeople.id == %@", userId)
        let predicate2 = NSPredicate(format: "status == %@", "DELIVERED")
        let predicate3 = NSPredicate(format: "myStatus != %@", "READ")
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])
        fetchRequest.predicate = compoundPredicate
        
        let numberUnread = dataController.executeFetchRequest(fetchRequest)!.count
        
        print(numberUnread)
        application.applicationIconBadgeNumber = numberUnread
    }
    
}

