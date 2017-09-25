//
//  ViewController.swift
//  Sample App
//
//  Created by Jason Pan on 21/09/2017.
//  Copyright © 2017 ANT Development Studios. All rights reserved.
//

import UIKit
import ADSSocialFeedScrollView

class ViewController: UIViewController {
    
    var filterList: Set<ADSSocialFeedProvider> = [.Facebook, .Youtube, .Instagram, .WordPress, .SoundCloud]
    
    //*********************************************************************************************************
    // MARK: - Interface Builder objects
    //*********************************************************************************************************
    
    @IBOutlet weak var socialFeedScrollView: IntegratedSocialFeedScrollView!
    
    @IBAction func filterPostsAction() {
        self.socialFeedDefaultFilter()
    }
    
    //*********************************************************************************************************
    // MARK: - UI helpers
    //*********************************************************************************************************
    
    func socialFeedDefaultFilter() {
        self.filterList = []
        
        let alertController = UIAlertController(title: "Filter posts", message: "Which posts would like in your feed?", preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: {
            action in
            self.filterList.insert(.Facebook)
            self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList)
        }))
        alertController.addAction(UIAlertAction(title: "Youtube", style: .Default, handler: {
            action in
            self.filterList.insert(.Youtube)
            self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList)
        }))
        alertController.addAction(UIAlertAction(title: "Instagram", style: .Default, handler: {
            action in
            self.filterList.insert(.Instagram)
            self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList)
        }))
        alertController.addAction(UIAlertAction(title: "WordPress", style: .Default, handler: {
            action in
            self.filterList.insert(.WordPress)
            self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList)
        }))
        alertController.addAction(UIAlertAction(title: "SoundCloud", style: .Default, handler: {
            action in
            self.filterList.insert(.SoundCloud)
            self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList)
        }))
        alertController.addAction(UIAlertAction(title: "All", style: .Default, handler: {
            action in
            self.filterList.insert(.Facebook)
            self.filterList.insert(.Youtube)
            self.filterList.insert(.Instagram)
            self.filterList.insert(.WordPress)
            self.filterList.insert(.SoundCloud)
            self.socialFeedScrollView.displayFilteredPostsWithProviders(self.filterList)
        }))
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
                self.socialFeedScrollView.addAccounts(ADSSocialFeed.accounts, completion: {
                    ADSSocialFeed.setWordPressDisplayPostAction({
                        link in
                        
                        let webpageController = WebpageViewController(url: link)
                        self.navigationController?.pushViewController(webpageController, animated: true)
                    })
                    
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

