//
//  SoundCloudTrackView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 27/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import AVFoundation

class SoundCloudTrackView: ADSFeedPostView, PostViewProtocol {
    
    private let BASIC_PLAYLIST_ITEM_HEIGHT: CGFloat = 88
    
    var track: SoundCloudTrack!
    
    private var isPlaying: Bool = false
    
    private var playerItem: AVPlayerItem!
    private var hasUsedPlayerItem = false
    
    //*********************************************************************************************************
    // MARK: - Interface Builder Objects
    //*********************************************************************************************************
    
    @IBOutlet weak var trackThumbnailImageView          : UIImageView!
    @IBOutlet weak var trackTitleLabel                  : UILabel!
    @IBOutlet weak var trackCreatedDateLabel            : UILabel!
    
    @IBOutlet weak var playbackButton                   : UIButton!
    
    @IBAction func togglePlayback() {
        print("togglePlayback")
        
        if self.playerItem == nil {
            self.playerItem = AVPlayerItem(URL: NSURL(string: self.track.stream_url)!)
        }
        
        if self.isPlaying {
            self.playbackButton.setImage(UIImage(named: "SoundCloudPlay", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            
            ADSSocialFeed.sharedAVPlayer.pause()
            
        }else if !self.isPlaying {
            self.playbackButton.setImage(UIImage(named: "SoundCloudPause", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            
            if ADSSocialFeed.sharedAVPlayer.currentItem != self.playerItem {
                ADSSocialFeed.sharedAVPlayer.pause()
                ADSSocialFeed.updateAVPlayerUIStatusBlock()
                
                if self.hasUsedPlayerItem == false {
                    ADSSocialFeed.sharedAVPlayer = AVPlayer(playerItem: self.playerItem)
                    ADSSocialFeed.sharedAVPlayer.rate = 1.0;
                    
                    hasUsedPlayerItem = true
                }
            }
            
            ADSSocialFeed.sharedAVPlayer.play()
            
            ADSSocialFeed.updateAVPlayerUIStatusBlock = {
                self.playbackButton.setImage(UIImage(named: "SoundCloudPlay", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                self.isPlaying = false
                self.playerItem = nil
                self.hasUsedPlayerItem = false
            }
        }
        
        self.isPlaying = !self.isPlaying
    }
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    override func initialize() {
        super.initialize()
        
        self.frame.size.height = BASIC_PLAYLIST_ITEM_HEIGHT
        
        self.backgroundColor = UIColor.whiteColor()
        if debugColours { self.trackThumbnailImageView.backgroundColor = UIColor.greenColor() }
        
        self.clipsToBounds = true
        self.trackThumbnailImageView.clipsToBounds = true
        
        self.trackTitleLabel.text = self.track.title
        self.trackThumbnailImageView.downloadedFrom(link: self.track.artwork_url, contentMode: .ScaleToFill, handler: nil)
        self.trackCreatedDateLabel.text = ADSSocialDateFormatter.stringFromString(self.track.created_at, provider: .SoundCloud)
        
        let normalColour = UIColor(red: 255/255, green: 85/255, blue: 0, alpha: 1.0)
        self.playbackButton.tintColor = normalColour
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, track: SoundCloudTrack) {
        self.track = track
        super.init(frame: frame)
    }
    
    //*********************************************************************************************************
    // MARK: - PostViewProtocol
    //*********************************************************************************************************
    
    var provider: ADSSocialFeedProvider {
        return ADSSocialFeedProvider.SoundCloud
    }
    
    var postData: PostProtocol {
        return self.track
    }
    
    func refreshView() {
        // Do nothing.
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
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.backgroundColor = self.originalColor
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
