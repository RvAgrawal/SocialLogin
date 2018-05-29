//
//  AppDelegate.swift
//  SwiftTest
//
//  Created by Ravi Agrawal on 15/05/18.
//  Copyright © 2018 Ravi Agrawal. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import LinkedinSwift
import GoogleSignIn
import TwitterKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        TWTRTwitter.sharedInstance().start(withConsumerKey:"ICGU9Ghv7TF5VUSLF5V2NYoCy", consumerSecret:"S8AH7aa6uoVi2VR2I6Oz73w5JP6ynQWy0n9avnwz0upMlJ6AoV")
        
        GIDSignIn.sharedInstance().clientID = "1097021142251-ico6sfvli0noe51qnh4ukqa90grurvt4.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let isFBOpenUrl = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
        let isGoogleOpenUrl = GIDSignIn.sharedInstance().handle(url,
                                                                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let isTwitterOpenURL = TWTRTwitter.sharedInstance().application(app, open: url, options: options)

        
        if isFBOpenUrl {
            return true
        }
        if isGoogleOpenUrl {
            return true
        }
        if isTwitterOpenURL {
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
//        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject, UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url,
                                                                    sourceApplication: sourceApplication,
                                                                    annotation: annotation)
    
        if googleDidHandle {
            return googleDidHandle
        }
    
        if LinkedinSwiftHelper.shouldHandle(url) {
            return LinkedinSwiftHelper.application(application,
                                                   open: url,
                                                   sourceApplication: sourceApplication,
                                                   annotation: annotation
            )
        }
        
        return true
    }

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
//
//            NotificationCenter.default.post(
//                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
//                object: nil,
//                userInfo: ["statusText": "Signed in user:\n\(fullName)"])
        }
    }
}

