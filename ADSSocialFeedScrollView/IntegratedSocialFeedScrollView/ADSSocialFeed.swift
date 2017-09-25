//
//  ADSSocialFeed.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 20/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MBProgressHUD

let debugColours: Bool = false

public enum ADSSocialFeedProvider: Int {
    case Facebook
    case Youtube
    case Instagram
    case WordPress
    case SoundCloud
}

public enum ADSSocialFeedImageQualityLevel {
    case Low
    case Medium
    case High
    case Max
}

public struct ADSSocialFeedGlobal {
    public static var HUD_DISPLAY_VIEW: UIView!
    internal static var HUD_DISPLAY_WINDOW: UIWindow!
    
    public static var ROOT_VIEW_CONTROLLER: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController
    
    public var imageQualityLevel: ADSSocialFeedImageQualityLevel = .Medium
}

private class HudWindowViewController: UIViewController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

internal extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}

public class ADSSocialFeed {
    
    public static var sharedAVPlayer: AVPlayer = AVPlayer()
    public static var updateAVPlayerUIStatusBlock: () -> Void = {}
    
    public static var LOADING_DATA_MESSAGE: String = "Retrieving posts..."
    
    public class func initialize(completionHandler: () -> Void) {
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.windowLevel = (UIWindowLevelStatusBar + 1)
        
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.rootViewController = HudWindowViewController()
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.makeKeyAndVisible()
        
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
        
        // Clear HTTP cookies - causes caching issue. 
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        completionHandler()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), {
            ADSSocialFeed.fetchAccountDataInBackgroundWithCompletionHandler(nil)
        })
    }
    
    //*********************************************************************************************************
    // MARK: - NSURLSessionDataTask management
    //*********************************************************************************************************
    
    private static var currentTasks: [NSURLSessionDataTask] = [NSURLSessionDataTask]()
    
    internal class func addTask(task: NSURLSessionDataTask) {
        dispatch_async(dispatch_get_main_queue(), {
            self.currentTasks.append(task)
        })
    }
    
//    internal class func suspendTask(task: NSURLSessionDataTask) {
//        dispatch_async(dispatch_get_main_queue(), {
//            task.suspend()
//        })
//    }
    
    internal class func suspendAllTasks() {
        dispatch_async(dispatch_get_main_queue(), {
            for task in self.currentTasks {
                task.suspend()
            }
        })
    }
    
    internal class func removeAllTasks() {
        dispatch_async(dispatch_get_main_queue(), {
            print(self.currentTasks)
            self.currentTasks.removeAll()
            print(self.currentTasks)
        })
    }
    
    internal class func removeTask(task: NSURLSessionDataTask) {
        dispatch_async(dispatch_get_main_queue(), {
            self.currentTasks.removeObject(task)
        })
    }
    
    //*********************************************************************************************************
    // MARK: - Individual Youtube Playlist (p. unlisted playlists) support
    //*********************************************************************************************************
    
    public static var sYoutubePlaylistIds: Set<String> = Set<String>()
    internal static var sYoutubePlaylists: [YoutubePlaylist] = [YoutubePlaylist]()
    
    //*********************************************************************************************************
    // MARK: - Multi-account support
    //*********************************************************************************************************
    
    private(set) public static var accounts: [ADSSocialFeedAccount] = [ADSSocialFeedAccount]()
    
    public class func addAccount(account: ADSSocialFeedAccount) {
        ADSSocialFeed.accounts.append(account)
    }
    
    public class func addAccount(id id: String, provider: ADSSocialFeedProvider) {
        let account = ADSSocialFeedAccount(id: id, provider: provider)
        ADSSocialFeed.accounts.append(account)
    }
    
    public class func setFacebookAuthKey(authKey: String) {
        ADSSocialFeedFacebookAccountProvider.authKey = authKey
    }
    
    public class func setYoutubeAuthKey(authKey: String) {
        ADSSocialFeedYoutubeAccountProvider.authKey = authKey
    }
    
    public class func setInstagramAuthKey(authKey: String) {
        ADSSocialFeedInstagramAccountProvider.authKey = authKey
    }
    
    public class func setInstagramClientId(clientId: String) {
        ADSSocialFeedInstagramAccountProvider.clientId = clientId
    }
    
    public class func setInstagramRedirectURI(redirectURI: String) {
        ADSSocialFeedInstagramAccountProvider.redirectURI = redirectURI
    }
    
    public class func setWordPressDisplayPostAction(displayPostAction: (NSURL) -> Void) {
        ADSSocialFeedWordPressAccountProvider.displayPostAction = displayPostAction
    }
    
    public class func setSoundCloudClientId(clientId: String) {
        ADSSocialFeedSoundCloudAccountProvider.clientId = clientId
    }
    
    //*********************************************************************************************************
    // MARK: - Data Retrieval
    //*********************************************************************************************************
    
    public static var dataLoadCount: Int = 0
    public static var isLoading: Bool {
        return isLoadingData || ADSSocialFeed.dataLoadCount < ADSSocialFeed.accounts.count + ((ADSSocialFeed.sYoutubePlaylistIds.count <= 0) ? 0 : 1)
    }
    private static var isLoadingData: Bool = false
    
//    public class func fetchAccountDataInBackgroundWithCompletionHandler(block: (() -> Void)?) {
//        self.suspendAllTasks()
//        self.removeAllTasks()
//        
//        ADSSocialFeed.isLoadingData = true
//        ADSSocialFeed.dataLoadCount = 0
//        
//        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = false
//        let hud = MBProgressHUD.showHUDAddedTo(ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW, animated: true)
//        
//        hud.backgroundView.style = .SolidColor
//        hud.backgroundView.color = UIColor(white: 0, alpha: 00.7)
//        hud.mode = .AnnularDeterminate
//        //        hud.label.text = "Loading social media data..."
//        hud.label.text = ADSSocialFeed.LOADING_DATA_MESSAGE
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            dispatch_sync(dispatch_get_main_queue(), {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                    for account in ADSSocialFeed.accounts {
//                        
//                        let accountData = account.dataPayload
//                        
//                        if let facebookPage = accountData as? FacebookPage {
//                            facebookPage.fetchProfileInfoInBackgroundWithCompletionHandler() {
//                                NSLog("[ADSSocialFeedScrollView] Finished fetching Facebook data")
//                                ADSSocialFeed.dataLoadCount++
//                            }
//                        }else if let youtubeChannel = accountData as? YoutubeChannel {
//                            youtubeChannel.fetchChannelInfoInBackgroundWithCompletionHandler() {
//                                NSLog("[ADSSocialFeedScrollView] Finished fetching Youtube data")
//                                ADSSocialFeed.dataLoadCount++
//                            }
//                        }else if let instagramUser = accountData as? InstagramUser {
//                            instagramUser.fetchProfileInfoInBackgroundWithCompletionHandler({
//                                NSLog("[ADSSocialFeedScrollView] Finished fetching Instagram data")
//                                ADSSocialFeed.dataLoadCount++
//                            })
//                        }else if let wordPressPostCollection = accountData as? WordPressPostCollection {
//                            wordPressPostCollection.fetchPostsInBackgroundWithCompletionHandler({
//                                NSLog("[ADSSocialFeedScrollView] Finished fetching WordPress data")
//                                ADSSocialFeed.dataLoadCount++
//                            })
//                        }else if let soundCloudUser = accountData as? SoundCloudUser {
//                            soundCloudUser.fetchUserInBackgroundWithCompletionHandler({
//                                NSLog("[ADSSocialFeedScrollView] Finished fetching SoundCloud data")
//                                ADSSocialFeed.dataLoadCount++
//                            })
//                        }else {
//                            ADSSocialFeed.dataLoadCount++
//                        }
//                    }
//                    
//                    YoutubeChannel.fetchStandalonePlaylistsInBackground({
//                        NSLog("[ADSSocialFeedScrollView] Finished fetching YouTube standalone data")
//                        ADSSocialFeed.dataLoadCount++
//                    })
//                    
//                })
//            })
//            
//            repeat {
//                dispatch_async(dispatch_get_main_queue(), {
//                    hud.progress = Float(ADSSocialFeed.dataLoadCount) / Float(ADSSocialFeed.accounts.count + ((ADSSocialFeed.sYoutubePlaylistIds.count <= 0) ? 0 : 1))
//                })
//            } while ADSSocialFeed.dataLoadCount < ADSSocialFeed.accounts.count + ((ADSSocialFeed.sYoutubePlaylistIds.count <= 0) ? 0 : 1)
//            
//            dispatch_sync(dispatch_get_main_queue(), {
//                hud.progress = Float(ADSSocialFeed.dataLoadCount) / Float(ADSSocialFeed.accounts.count + ((ADSSocialFeed.sYoutubePlaylistIds.count <= 0) ? 0 : 1))
//            })
//            
//            dispatch_sync(dispatch_get_main_queue(), {
//                //                hud.hideAnimated(true)
//                //                ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
//                //
//                //                self.refreshAccountPosts()
//                //
//                //                //NOTE: For filter persistence
//                //                self.displayFilteredPostsWithProviders(self.providerFilterList)
//                
//                ///////*******DEBUG ONLY*********/////////
//                for account in ADSSocialFeed.accounts {
//                    if let instagramUser = account.dataPayload as? InstagramUser {
//                        NSLog("[ADSSocialFeed][Instagram]: Retrieved posts: \(instagramUser.posts)")
//                    }
//                }
//                ///////*******DEBUG ONLY*********/////////
//                
//                hud.hideAnimated(true)
//                ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
//                
//                ADSSocialFeed.isLoadingData = false
//                
//                block?()
//            })
//        })
//    }
    
    
    private class func fetchComplete(hud: MBProgressHUD, block: (() -> Void)?) {
        dispatch_async(dispatch_get_main_queue(), {
            print(ADSSocialFeed.dataLoadCount)
            
            ADSSocialFeed.dataLoadCount += 1
            
            hud.progress = Float(ADSSocialFeed.dataLoadCount) / Float(ADSSocialFeed.accounts.count + ((ADSSocialFeed.sYoutubePlaylistIds.count <= 0) ? 0 : 1))
            
            if ADSSocialFeed.dataLoadCount < ADSSocialFeed.accounts.count + ((ADSSocialFeed.sYoutubePlaylistIds.count <= 0) ? 0 : 1) {
                return
            }
            
            //                hud.hideAnimated(true)
            //                ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
            //
            //                self.refreshAccountPosts()
            //
            //                //NOTE: For filter persistence
            //                self.displayFilteredPostsWithProviders(self.providerFilterList)
            
            ///////*******DEBUG ONLY*********/////////
            for account in ADSSocialFeed.accounts {
                if let instagramUser = account.dataPayload as? InstagramUser {
                    NSLog("[ADSSocialFeed][Instagram]: Retrieved posts: \(instagramUser.posts)")
                }
            }
            ///////*******DEBUG ONLY*********/////////
            
            hud.hideAnimated(true)
            ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
            
            ADSSocialFeed.isLoadingData = false
            
            block?()
        })
    }

    public class func fetchAccountDataInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        self.suspendAllTasks()
        self.removeAllTasks()
        
        ADSSocialFeed.isLoadingData = true
        ADSSocialFeed.dataLoadCount = 0
        
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = false
        let hud = MBProgressHUD.showHUDAddedTo(ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW, animated: true)
        
        hud.backgroundView.style = .SolidColor
        hud.backgroundView.color = UIColor(white: 0, alpha: 00.7)
        hud.mode = .AnnularDeterminate
        //        hud.label.text = "Loading social media data..."
        hud.label.text = ADSSocialFeed.LOADING_DATA_MESSAGE
        
        for account in ADSSocialFeed.accounts {
            print("\(account)")
            
            let accountData = account.dataPayload
            
            if let facebookPage = accountData as? FacebookPage {
                facebookPage.fetchProfileInfoInBackgroundWithCompletionHandler() {
                    NSLog("[ADSSocialFeedScrollView] Finished fetching Facebook data")
                    ADSSocialFeed.fetchComplete(hud, block: block)
                }
            }else if let youtubeChannel = accountData as? YoutubeChannel {
                youtubeChannel.fetchChannelInfoInBackgroundWithCompletionHandler() {
                    NSLog("[ADSSocialFeedScrollView] Finished fetching Youtube data")
                    ADSSocialFeed.fetchComplete(hud, block: block)
                }
            }else if let instagramUser = accountData as? InstagramUser {
                instagramUser.fetchProfileInfoInBackgroundWithCompletionHandler({
                    NSLog("[ADSSocialFeedScrollView] Finished fetching Instagram data")
                    ADSSocialFeed.fetchComplete(hud, block: block)
                })
            }else if let wordPressPostCollection = accountData as? WordPressPostCollection {
                wordPressPostCollection.fetchPostsInBackgroundWithCompletionHandler({
                    NSLog("[ADSSocialFeedScrollView] Finished fetching WordPress data")
                    ADSSocialFeed.fetchComplete(hud, block: block)
                })
            }else if let soundCloudUser = accountData as? SoundCloudUser {
                soundCloudUser.fetchUserInBackgroundWithCompletionHandler({
                    NSLog("[ADSSocialFeedScrollView] Finished fetching SoundCloud data")
                    ADSSocialFeed.fetchComplete(hud, block: block)
                })
            }else {
                ADSSocialFeed.fetchComplete(hud, block: block)
            }
        }
        
        YoutubeChannel.fetchStandalonePlaylistsInBackground({
            NSLog("[ADSSocialFeedScrollView] Finished fetching YouTube standalone data")
            ADSSocialFeed.fetchComplete(hud, block: block)
        })
    }

}
