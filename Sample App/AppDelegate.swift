//
//  AppDelegate.swift
//  Sample App
//
//  Created by Jason Pan on 21/09/2017.
//  Copyright © 2017 ANT Development Studios. All rights reserved.
//

import UIKit
import ADSSocialFeedScrollView
import XCDYouTubeKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set up
        ADSSocialFeed.initialize({
            // Set up service authentication keys.
            ADSSocialFeed.setFacebookAuthKey("__YOUR_FACEBOOK_AUTH_KEY__")
            
            ADSSocialFeed.setYoutubeAuthKey("__YOUR_YOUTUBE_AUTH_KEY__")
            
            ADSSocialFeed.setInstagramAuthKey("__YOUR_INSTAGRAM_AUTH_KEY__")
            ADSSocialFeed.setInstagramClientId("__YOUR_INSTAGRAM_CLIENT_ID__")
            ADSSocialFeed.setInstagramRedirectURI("__YOUR_INSTAGRAM_REDIRECT_URI__")
            
            ADSSocialFeed.setSoundCloudClientId("__YOUR_SOUNDCLOUD_CLIENT_ID__")
            
            // Set up social feed accounts.
            let facebookPageId      = "__FACEBOOK_PAGE_ID__"
            let youtubeChannelId    = "__YOUTUBE_CHANNEL_ID__"
            let instagramUserId     = "__INSTAGRAM_USER_ID__"
            let wordpressSiteUrl    = "__WORDPRESS_SITE_URL__"
            let soundcloudUserId    = "__SOUNDCLOUD_USER_ID__"
            
            ADSSocialFeed.addAccount(id: facebookPageId,                provider: .Facebook)
            ADSSocialFeed.addAccount(id: youtubeChannelId,              provider: .Youtube)
            ADSSocialFeed.addAccount(id: instagramUserId,               provider: .Instagram)
            ADSSocialFeed.addAccount(id: wordpressSiteUrl,              provider: .WordPress)
            ADSSocialFeed.addAccount(id: soundcloudUserId,              provider: .SoundCloud)
        })
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if self.window?.rootViewController?.presentedViewController is XCDYouTubeVideoPlayerViewController {
            
            let secondController = self.window!.rootViewController!.presentedViewController as! XCDYouTubeVideoPlayerViewController
            
            if !secondController.isBeingDismissed() {
                return UIInterfaceOrientationMask.All
            } else {
                return UIInterfaceOrientationMask.Portrait
            }
        } else {
            return UIInterfaceOrientationMask.Portrait
        }
        
    }


}

