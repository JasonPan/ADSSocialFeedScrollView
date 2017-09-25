//
//  YoutubePlaylistItemView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 14/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import MBProgressHUD
import XCDYouTubeKit

class YoutubePlaylistItemView: ADSFeedPostView, IntegratedSocialFeedPostViewProtocol {
    
    private let BASIC_PLAYLIST_ITEM_HEIGHT: CGFloat = 88
    
    var playlistItem: YoutubeVideo!
    
    private var isPlaying: Bool = false
    
    //*********************************************************************************************************
    // MARK: - Interface Builder Objects
    //*********************************************************************************************************
    
    @IBOutlet weak var playlistItemThumbnailImageView       : UIImageView!
    @IBOutlet weak var playlistItemTitleLabel               : UILabel!
    @IBOutlet weak var playlistItemPublishedDateLabel       : UILabel!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    override func initialize() {
        super.initialize()
        
        self.frame.size.height = BASIC_PLAYLIST_ITEM_HEIGHT
        
        self.backgroundColor = UIColor.whiteColor()
        if debugColours { self.playlistItemThumbnailImageView.backgroundColor = UIColor.greenColor() }
        
        self.clipsToBounds = true
        self.playlistItemThumbnailImageView.clipsToBounds = true
        
        self.playlistItemTitleLabel.text = self.playlistItem.title
        self.playlistItemThumbnailImageView.downloadedFrom(link: self.playlistItem.thumbnailImageURL, contentMode: .ScaleToFill, handler: nil)
        self.playlistItemPublishedDateLabel.text = ADSSocialDateFormatter.stringFromString(self.playlistItem.publishedAt, provider: .Youtube)
        
        self.playlistItemThumbnailImageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, playlistItem: YoutubeVideo) {
        self.playlistItem = playlistItem
        super.init(frame: frame)
    }
    
    //*********************************************************************************************************
    // MARK: - IntegratedSocialFeedPostViewProtocol
    //*********************************************************************************************************
    
    var provider: ADSSocialFeedProvider {
        return ADSSocialFeedProvider.Youtube
    }
    
    var postData: IntegratedSocialFeedPostProtocol {
        return self.playlistItem
    }
    
    //*********************************************************************************************************
    // MARK: - Touch handlers
    //*********************************************************************************************************
    
    var originalColor: UIColor? = nil
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.originalColor = self.backgroundColor
        self.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.backgroundColor = self.originalColor
        
        let videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: self.playlistItem.id)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: videoPlayerViewController.moviePlayer)
        
        videoPlayerViewController.moviePlayer.play()
        
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = false
        let hud = MBProgressHUD.showHUDAddedTo(ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW, animated: true)
        hud.backgroundView.style = .SolidColor//.Blur
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.7)
        
        hud.label.text = "Loading video..."
        
        self.isPlaying = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            repeat {} while !videoPlayerViewController.moviePlayer.isPreparedToPlay && self.isPlaying == true
            
            dispatch_async(dispatch_get_main_queue(), {
                hud.hideAnimated(true)
                self.isPlaying = false
                ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
                
                if videoPlayerViewController.moviePlayer.isPreparedToPlay {
                    ADSSocialFeedGlobal.ROOT_VIEW_CONTROLLER?.presentMoviePlayerViewControllerAnimated(videoPlayerViewController)
                }
            })
        })
        
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.backgroundColor = self.originalColor
    }
    
    //*********************************************************************************************************
    // MARK: - MPMoviePlayerPlaybackDidFinishNotification
    //*********************************************************************************************************
    
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: notification.object)
        let finishReason: MPMovieFinishReason = MPMovieFinishReason(rawValue: notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! Int)!
        if (finishReason == MPMovieFinishReason.PlaybackError) {
            if let error = notification.userInfo?[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey] as? NSError {
                NSLog("[ADSSocialFeedScrollView][Youtube] An error occurred while playing video: \(error.description)")
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                ADSSocialFeedGlobal.ROOT_VIEW_CONTROLLER?.presentViewController(alert, animated: true, completion: nil)
            }
            
            // Handle error
            self.isPlaying = false
        }
    }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
