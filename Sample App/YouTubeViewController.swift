//
//  YouTubeViewController.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 22/09/2017.
//  Copyright © 2017 ANT Development Studios. All rights reserved.
//

import UIKit
import ADSSocialFeedScrollView

class YouTubeViewController: UIViewController {
    
    var youtubeAccount: ADSSocialFeedAccount!
    
    var filterList: Set<ADSSocialFeedProvider> = [.Youtube]
    
    //*********************************************************************************************************
    // MARK: - Interface Builder objects
    //*********************************************************************************************************
    
    @IBOutlet weak var socialFeedScrollView: IntegratedSocialFeedScrollView!
    
    @IBAction func filterPostsAction() {
        self.youtubePlaylistFilter()
    }
    
    //*********************************************************************************************************
    // MARK: - UI helpers
    //*********************************************************************************************************
    
    func youtubePlaylistFilter() {
        let alertController = UIAlertController(title: "Filter playlists", message: "Which playlists would you like to see?", preferredStyle: .ActionSheet)
        
        if let playlistTitles = socialFeedScrollView.youtubePlaylistTitlesForAccount(self.youtubeAccount) {
            for title in playlistTitles {
                
                alertController.addAction(UIAlertAction(title: title, style: .Default, handler: {
                    action in
                    self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList, accountFilters: [self.youtubeAccount : [title]])
                }))
            }
            alertController.addAction(UIAlertAction(title: "All", style: .Default, handler: {
                action in
                self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList, accountFilters: [self.youtubeAccount : playlistTitles])
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            action in
            //Do nothing
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //*********************************************************************************************************
    // MARK: - View lifecycle
    //*********************************************************************************************************
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let textColour: UIColor = UIColor(white: 236/255, alpha: 1)
        let colour: UIColor = UIColor(netHex: 0x249cd4)
        
        self.navigationController?.navigationBar.tintColor = textColour
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: textColour]
        self.navigationController?.navigationBar.barTintColor = colour
        
        self.socialFeedScrollView.backgroundColor = colour
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            repeat {} while ADSSocialFeed.isLoading || ADSSocialFeed.accounts.count == 0
            
            dispatch_async(dispatch_get_main_queue(), {
                self.youtubeAccount = ADSSocialFeedAccount.accountForId("__YOUTUBE_CHANNEL_ID__", provider: .Youtube)
                self.socialFeedScrollView.addAccount(self.youtubeAccount, completion: {
                    self.socialFeedScrollView.refreshSocialFeed()
                })
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
