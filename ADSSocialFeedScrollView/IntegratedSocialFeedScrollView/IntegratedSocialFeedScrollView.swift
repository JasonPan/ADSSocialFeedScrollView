//
//  IntegratedSocialFeedScrollView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 15/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import MBProgressHUD

public class IntegratedSocialFeedScrollView: UIScrollView, UIScrollViewDelegate {
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    private var __postViewBottomLayoutConstraint: NSLayoutConstraint!
    private var __loadViewTopLayoutConstraint: NSLayoutConstraint!
    private var __loadViewHeightLayoutConstraint: NSLayoutConstraint!
    private var __scrollViewBottomLayoutConstraint: NSLayoutConstraint!
    private var __scrollViewRightLayoutConstraint: NSLayoutConstraint!
    
    //*********************************************************************************************************
    // MARK: - Data filtering
    //*********************************************************************************************************
    
    var providerFilterList: Set<ADSSocialFeedProvider> = [.Facebook, .Youtube, .Instagram, .WordPress, .SoundCloud]
    private(set) var accounts: [ADSSocialFeedAccount] = [ADSSocialFeedAccount]()
    
    public func addAccount(account: ADSSocialFeedAccount, completion block: (() -> Void)?) {
        
        var needsProcessing = true
        
        if ADSSocialFeed.accounts.contains(account) == false {
            print("addAccount")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var hasLoaded = false
                var hud: MBProgressHUD!
                
                dispatch_sync(dispatch_get_main_queue(), {
                    ADSSocialFeed.addAccount(account)
                    
                    
                    
                    
                    ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = false
                    hud = MBProgressHUD.showHUDAddedTo(ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW, animated: true)
                    
                    hud.backgroundView.style = .SolidColor
                    hud.backgroundView.color = UIColor(white: 0, alpha: 00.7)
                    //        hud.mode = .AnnularDeterminate
                    hud.label.text = ADSSocialFeed.LOADING_DATA_MESSAGE
                    
                    
                    
                    let accountData = account.dataPayload
                    
                    let completionBlock = {
                        ADSSocialFeed.dataLoadCount += 1
                        
                        hasLoaded = true
                    }
                    
                    if let facebookPage = accountData as? FacebookPage {
                        facebookPage.fetchProfileInfoInBackgroundWithCompletionHandler() {
                            NSLog("[ADSSocialFeedScrollView] Finished fetching Facebook data")
                            completionBlock()
                        }
                    }else if let youtubeChannel = accountData as? YoutubeChannel {
                        youtubeChannel.fetchChannelInfoInBackgroundWithCompletionHandler() {
                            NSLog("[ADSSocialFeedScrollView] Finished fetching Youtube data")
                            completionBlock()
                        }
                    }else if let instagramUser = accountData as? InstagramUser {
                        instagramUser.fetchProfileInfoInBackgroundWithCompletionHandler({
                            NSLog("[ADSSocialFeedScrollView] Finished fetching Instagram data")
                            completionBlock()
                        })
                    }else if let wordPressPostCollection = accountData as? WordPressPostCollection {
                        wordPressPostCollection.fetchPostsInBackgroundWithCompletionHandler({
                            NSLog("[ADSSocialFeedScrollView] Finished fetching WordPress data")
                            completionBlock()
                        })
                    }else if let soundCloudUser = accountData as? SoundCloudUser {
                        soundCloudUser.fetchUserInBackgroundWithCompletionHandler({
                            NSLog("[ADSSocialFeedScrollView] Finished fetching SoundCloud data")
                            completionBlock()
                        })
                    }else {
                        completionBlock()
                    }
                })
                
                print("test1: \(ADSSocialFeed.dataLoadCount)")
                print("test2: \(ADSSocialFeed.accounts.count)")
                //                repeat {} while ADSSocialFeed.dataLoadCount < ADSSocialFeed.accounts.count
                repeat {} while hasLoaded == false
                
                dispatch_sync(dispatch_get_main_queue(), {
                    //                hud.progress = 1.0
                    
                    hud.hideAnimated(true)
                    ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
                    
                    block?()
                })
            })
        }else {
            needsProcessing = false
        }
        
        if self.accounts.contains(account) == false {
            self.accounts.append(account)
        }
        
        if !needsProcessing {
            //            dispatch_async(dispatch_get_main_queue(), {
            block?()
            //            })
            //            block?()
        }
        
    }
    
    public func addAccount(id id: String, provider: ADSSocialFeedProvider, completion block: (() -> Void)?) {
        let account = ADSSocialFeedAccount(id: id, provider: provider)
        self.addAccount(account, completion: block)
    }
    
    public func addAccounts(accounts: [ADSSocialFeedAccount], completion block: (() -> Void)?) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var loadCount = 0
            
            for account in accounts {
                self.addAccount(account, completion: {
                    loadCount += 1
                    
                    if loadCount >= accounts.count {
                        block?()
                    }
                })
            }
            
//            repeat {} while loadCount < accounts.count
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                block?()
//            })
//        })
    }
    
    public func removeAllAccount() {
        self.accounts = [ADSSocialFeedAccount]()
    }
    
//    public func addAccount(account: ADSSocialFeedAccount) {
//        if ADSSocialFeed.accounts.contains(account) == false {
//            ADSSocialFeed.addAccount(account)
//        }
//        if self.accounts.contains(account) == false {
//            self.accounts.append(account)
//        }
//    }
//    
//    public func addAccount(id id: String, provider: ADSSocialFeedProvider) {
//        let account = ADSSocialFeedAccount(id: id, provider: provider)
//        self.addAccount(account)
//    }
//    
//    public func addAccounts(accounts: [ADSSocialFeedAccount]) {
//        for account in accounts {
//            self.addAccount(account)
//        }
//    }
//    
//    public func removeAllAccount() {
//        self.accounts = [ADSSocialFeedAccount]()
//    }
    
    //*********************************************************************************************************
    // MARK: - LoadMoreView implementation
    //*********************************************************************************************************
    var loadMoreView: ADSLoadIndicatorView!
    
    func setupLoadMoreView() {
        if self.loadMoreView == nil {
            self.loadMoreView = ADSLoadIndicatorView(frame: CGRect(origin: CGPointMake(0, self.contentSize.height), size: DEVICE_SCREEN_SIZE))
            self.loadMoreView.translatesAutoresizingMaskIntoConstraints = false
            
            //Fix for scroll bar hidden by subviews issue
            //See: http://stackoverflow.com/a/2019582/699963
            self.insertSubview(self.loadMoreView, atIndex: 0)
            
            self.addConstraint(NSLayoutConstraint(
                item: self,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.loadMoreView,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1,
                constant: 0))
            
            self.addConstraint(NSLayoutConstraint(
                item: self.loadMoreView,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1,
                constant: 0))
            
            self.__loadViewHeightLayoutConstraint = NSLayoutConstraint(
                item: self.loadMoreView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: 60)
            self.addConstraint(self.__loadViewHeightLayoutConstraint)
            
            if self.__loadViewTopLayoutConstraint == nil {
                self.__loadViewTopLayoutConstraint = NSLayoutConstraint(
                    item: self,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.loadMoreView,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1,
                    constant: 60 + GENERIC_POST_SEPARATOR_HEIGHT)
                self.addConstraint(self.__loadViewTopLayoutConstraint)
            }
            
            self.layoutIfNeeded()
        }
    }
    
    func updateLoadMoreViewLocation() {
        self.setupLoadMoreView()
        if self.displayedPostViews.count < self.filteredPostViews.count {
            self.loadMoreView.hidden = false
            self.__loadViewHeightLayoutConstraint.constant = 60
        }else {
            self.loadMoreView.hidden = true
            self.__loadViewHeightLayoutConstraint.constant = 15
        }
    }
    
    //SIDENOTE: Investigate WHY public is required.
    //See: http://stackoverflow.com/a/28329743/699963
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.loadMoreView != nil {
            
            if self.loadMoreView.isRefreshing() {
                return
            }
            
            if self.loadMoreView.hidden == false {
                if self.displayedPostViews.count == self.filteredPostViews.count {
                    
                    self.loadMoreView.hidden = true
//                    self.loadMoreView.center = CGPointZero
                    
//                    self.layoutIfNeeded()
                }else {
                    guard scrollView.frame.size.height < self.loadMoreView.frame.origin.y else {
                        return
                    }
                    
                    if scrollView.contentOffset.y + scrollView.frame.size.height >= self.loadMoreView.frame.origin.y {
                        self.loadMoreView.startRefreshing()
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                            self.loadNextPosts(10) {
                                self.loadMoreView.stopRefreshing()
                            }
                        })
                    }
                }
            }
        }
    }
    
    func loadNextPosts(count: Int, block: (Void -> ())?) {
        print("loadNextPosts: \(self.displayedPostViews.count)")
        let safeCount = min(self.displayedPostViews.count + count, self.filteredPostViews.count)
        
        let initCount = self.displayedPostViews.count
//        for var i = self.displayedPostViews.count; i < safeCount; i++ { //SELFNOTE: DODGY!!!
        for var i = initCount; i < safeCount; i++ {
            self.displayedPostViews.append(self.filteredPostViews[i])
            let postView = self.displayedPostViews[i] as! UIView
            
            //Fix for scroll bar hidden by subviews issue
            //See: http://stackoverflow.com/a/2019582/699963
            self.insertSubview(postView, atIndex: 0)
        }
        
        let startCount = initCount//0
        for var i: Int = startCount; i < safeCount; i++ {
            let postView = self.displayedPostViews[i] as! UIView
            
            var previousPostView: UIView? = nil
            if i > 0 {
                previousPostView = self.displayedPostViews[i - 1] as! UIView
            }
            self.setUpConstraintsForPostView(postView, previousPostView: previousPostView, isFinalView: i == safeCount - 1)
        }
    
        self.updateLoadMoreViewLocation()
        
        if block != nil { block!() }
    }
    
    //*********************************************************************************************************
    // MARK: - UIRefreshControl
    //*********************************************************************************************************
    
    //UIScrollView with UIRefresh control "jumping issue" fix
    //See: http://stackoverflow.com/a/34868331/699963
    public override var contentInset: UIEdgeInsets {
        willSet {
            if self.tracking {
                let diff = newValue.top - self.contentInset.top;
                var translation = self.panGestureRecognizer.translationInView(self)
                translation.y -= diff * 3.0 / 2.0
                self.panGestureRecognizer.setTranslation(translation, inView: self)
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.performSelector("initialize", withObject: nil, afterDelay: 0)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.performSelector("initialize", withObject: nil, afterDelay: 0)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.performSelector("initialize", withObject: nil, afterDelay: 0)
    }
    
    public func initialize() {
        
        self.refreshControl.addTarget(self, action: "refreshControlDidRefresh:", forControlEvents: .ValueChanged)
        
        self.addSubview(self.refreshControl)
        
        self.delegate = self
        self.alwaysBounceVertical = true //See: http://stackoverflow.com/a/13095480/699963 #Verify ref| neccesity
        
//        ADSSocialFeedGlobal.HUD_DISPLAY_VIEW = self.superview! #Verify functionality!!!
    }
    
    func refreshControlDidRefresh(sender: UIRefreshControl) { //TODO: Investigate why can't be made private
        sender.endRefreshing()
//        self.refreshSocialFeed()
        
        ADSSocialFeed.dataLoadCount = 0
        ADSSocialFeed.fetchAccountDataInBackgroundWithCompletionHandler({
            self.refreshSocialFeed()
        })
    }
    
    // Fix: UIRefreshControl animation glitch upon ViewController viewDidDisappear (such as pushViewController)
    // See: http://stackoverflow.com/a/26008140/699963
    public override func updateConstraints() {
        super.updateConstraints()
        
        self.refreshControl.endRefreshing()
    }
    
    //*********************************************************************************************************
    // MARK: - Miscellaneous
    //*********************************************************************************************************
    
    private let GENERIC_POST_SEPARATOR_HEIGHT: CGFloat = 8
    
    private let POST_SEPARATOR_COLOUR: UIColor = UIColor(red: 211/255, green: 214/255, blue: 219/255, alpha: 1.0) //
    
    
    
    //*********************************************************************************************************
    // MARK: - Feed Display Items
    //*********************************************************************************************************
    
    private var displayedPostViews  : [PostViewProtocol]    = []
    private var filteredPostViews   : [PostViewProtocol]    = []
    private var postViews           : [PostViewProtocol]    = []
    
    private func setUpConstraintsForPostView(postView: UIView, previousPostView: UIView?, isFinalView: Bool) {
        
        if let postView = postView as? ADSFeedPostView {
            
            self.translatesAutoresizingMaskIntoConstraints = false
            postView.translatesAutoresizingMaskIntoConstraints = false
            
            if isFinalView {
                
                if self.loadMoreView != nil {
                    
                    self.__loadViewTopLayoutConstraint?.active = false
                    self.__loadViewTopLayoutConstraint = NSLayoutConstraint(
                        item: postView,
                        attribute: NSLayoutAttribute.Bottom,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: self.loadMoreView,
                        attribute: NSLayoutAttribute.Top,
                        multiplier: 1,
                        constant: 0)
                    self.__loadViewTopLayoutConstraint.active = true
                    
                    
                    self.__scrollViewBottomLayoutConstraint?.active = false
                    self.__scrollViewBottomLayoutConstraint = NSLayoutConstraint(
                        item: self,
                        attribute: NSLayoutAttribute.Bottom,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: self.loadMoreView,
                        attribute: NSLayoutAttribute.Bottom,
                        multiplier: 1,
                        constant: 0)
                    self.__scrollViewBottomLayoutConstraint.active = true
                    
                    
                    self.__scrollViewRightLayoutConstraint?.active = false
                    self.__scrollViewRightLayoutConstraint = NSLayoutConstraint(
                        item: self,
                        attribute: NSLayoutAttribute.Right,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: self.loadMoreView,
                        attribute: NSLayoutAttribute.Right,
                        multiplier: 1,
                        constant: 0)
                    self.__scrollViewRightLayoutConstraint.active = true
                }
            }
            
            
            
            postView.__postViewWidthLayoutConstraint?.active = false
            postView.__postViewCentreXLayoutConstraint?.active = false
            postView.__postViewTopLayoutConstraint?.active = false
//            postView.__postViewHeightLayoutConstraint?.active = false
            postView.setNeedsLayout()
            
            
            
            postView.__postViewWidthLayoutConstraint = NSLayoutConstraint(
                item: postView,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: UIScreen.mainScreen().bounds.size.width)
            postView.__postViewWidthLayoutConstraint.active = true
            
            postView.__postViewCentreXLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: postView,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1,
                constant: 0)
            postView.__postViewCentreXLayoutConstraint.active = true
            
            if let previousPostView = previousPostView {
                postView.__postViewTopLayoutConstraint = NSLayoutConstraint(
                    item: previousPostView,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: postView,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1,
                    constant: -GENERIC_POST_SEPARATOR_HEIGHT)
            }else {
                postView.__postViewTopLayoutConstraint = NSLayoutConstraint(
                    item: self,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: postView,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1,
                    constant: -GENERIC_POST_SEPARATOR_HEIGHT)//0)
            }
            postView.__postViewTopLayoutConstraint.active = true
            
            if postView.__postViewHeightLayoutConstraint == nil {
                postView.__postViewHeightLayoutConstraint = NSLayoutConstraint(
                    item: postView,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: postView.frame.size.height) //TODO: Create generic class-scope constant
            }
            postView.__postViewHeightLayoutConstraint.active = true
            
            if postView.__postViewHeightLayoutConstraint.constant == 0 {
                postView.__postViewHeightLayoutConstraint.constant = postView.frame.size.height
            }
            
            
//            self.layoutIfNeeded()
        }
        
    }
    
    private func displayPosts() {
        
        for subview in self.subviews {
            if let _ = subview as? PostViewProtocol {
                subview.removeFromSuperview()
            }
        }
        
        self.scrollRectToVisible(self.bounds, animated: true)
        
        //Fix for scrollViewDidScroll triggered programmatically issue
        //See: http://stackoverflow.com/a/17856354/699963
        self.delegate = self
        
        for var i: Int = 0; i < self.displayedPostViews.count; i++ {
            let postView = self.displayedPostViews[i] as! UIView
            
            //Fix for scroll bar hidden by subviews issue
            //See: http://stackoverflow.com/a/2019582/699963
            self.insertSubview(postView, atIndex: 0)
            
            var previousPostView: UIView? = nil
            if i > 0 {
                previousPostView = self.displayedPostViews[i - 1] as! UIView
            }
            self.setUpConstraintsForPostView(postView, previousPostView: previousPostView, isFinalView: i == self.displayedPostViews.count - 1)
        }
        
        self.updateLoadMoreViewLocation()
    }
    
    //*********************************************************************************************************
    // MARK: - Data loading safety variables
    //*********************************************************************************************************
    
    var isLoadingData: Bool {
        get {
            return self.dataLoadCount < self.accounts.count
        }
        set {
            self.dataLoadCount = newValue ? 0 : self.accounts.count
        }
    }
    
    var isLoadingFeed: Bool {
        get {
            // NOTE: Investigate whether '==' is sufficient (it probably is)
            return self.feedLoadCount < self.accounts.count + ((ADSSocialFeed.sYoutubePlaylists.count <= 0) ? 0 : 1)
        }
        set {
            self.feedLoadCount = newValue ? 0 : self.accounts.count + ((ADSSocialFeed.sYoutubePlaylists.count <= 0) ? 0 : 1)
        }
    }
    
    private var dataLoadCount: Int = 0
    private var feedLoadCount: Int = 0
    
    //*********************************************************************************************************
    // MARK: - Display
    //*********************************************************************************************************
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = POST_SEPARATOR_COLOUR//UIColor.lightGrayColor()
        self.delaysContentTouches = false
    }
    
    public func refreshSocialFeed() { //Display?
        ADSSocialFeed.sharedAVPlayer.pause()
        ADSSocialFeed.updateAVPlayerUIStatusBlock()
        
        ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = false
        let hud = MBProgressHUD.showHUDAddedTo(ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW, animated: true)
        
        hud.backgroundView.style = .SolidColor
        hud.backgroundView.color = UIColor(white: 0, alpha: 00.7)
//        hud.mode = .AnnularDeterminate
////        hud.label.text = "Loading social media data..."
//        hud.label.text = ADSSocialFeed.LOADING_DATA_MESSAGE
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            dispatch_sync(dispatch_get_main_queue(), {
                hud.progress = Float(self.dataLoadCount) / Float(self.accounts.count)
            })
            
            dispatch_sync(dispatch_get_main_queue(), {
                
                ///////*******DEBUG ONLY*********/////////
                for account in self.accounts {
                    if let instagramUser = account.dataPayload as? InstagramUser {
                        NSLog("[ADSSocialFeedScrollView][Instagram]: Retrieved posts: \(instagramUser.posts)")
                    }
                }
                ///////*******DEBUG ONLY*********/////////
                
                hud.label.text = "Loading feed..."
                hud.mode = .Indeterminate
                
                self.refreshAccountPosts()
                
                //NOTE: For filter persistence
                self.displayFilteredPostsWithProviders(self.providerFilterList)
                
                hud.hideAnimated(true)
                ADSSocialFeedGlobal.HUD_DISPLAY_WINDOW.hidden = true
            })
        })
    }
    
    private func refreshAccountPosts() {
        self.isLoadingFeed = true
        
        self.postViews.removeAll()
        
        for account in self.accounts {
            let accountData = account.dataPayload
            
            if let facebookPage = accountData as? FacebookPage {
                self.reloadPostsInCollection(facebookPage)
            }
            if let youtubeChannel = accountData as? YoutubeChannel {
                self.reloadPostsInCollection(youtubeChannel)
            }
            if let instagramUser = accountData as? InstagramUser {
                self.reloadPostsInCollection(instagramUser)
            }
            if let wordPressPostCollection = accountData as? WordPressPostCollection {
                self.reloadPostsInCollection(wordPressPostCollection)
            }
            if let soundCloudUser = accountData as? SoundCloudUser {
                self.reloadPostsInCollection(soundCloudUser)
            }
        }
        
        // NOTE: Only display standalone YouTube playlists if there exists other (channel) playlists.
        if self.postViews.contains({ $0.provider == .Youtube }) {
            self.refreshIndividualYoutubePlaylistItems()
        }
        
        self.isLoadingFeed = false
    }
    
    /// Reload post views for the given post collection.
    private func reloadPostsInCollection(collection: PostCollectionProtocol) {
        guard let posts = collection.postItems else { return }
        
        var postViews: [PostViewProtocol] = []
        
        for post in posts {
            
            var postView: PostViewProtocol!
            
            if let post = post as? FacebookPost {
                postView = FacebookPostView(frame: CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, 0), post: post)
            }else if let post = post as? YoutubeVideo {
                postView = YoutubePlaylistItemView(frame: CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, 0), playlistItem: post)
            }else if let post = post as? InstagramPost {
                let maxWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
                postView = InstagramPostView(frame: CGRectMake(0, 0, maxWidth, 0), post: post)
            }else if let post = post as? WordPressPost {
                postView = WordPressPostView(frame: CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, 0), post: post, readMoreAction: ADSSocialFeedWordPressAccountProvider.displayPostAction)
            }else if let post = post as? SoundCloudTrack {
                postView = SoundCloudTrackView(frame: CGRectMake(0, 0, DEVICE_SCREEN_WIDTH, 0), track: post)
            }
            
            postView.refreshView()
            
            postViews.append(postView)
            
        }
        
        self.postViews += postViews
    }
    
    private func refreshIndividualYoutubePlaylistItems() {
        let exitBlock = {
            self.feedLoadCount++
        }
        
        guard ADSSocialFeed.sYoutubePlaylists.count > 0 else {
            exitBlock()
            return
        }
        
        for playlist in ADSSocialFeed.sYoutubePlaylists {
            self.reloadPostsInCollection(playlist)
        }
        
        exitBlock()
    }
    
    public func displayFilteredPostsWithProviders(providers: Set<ADSSocialFeedProvider>) {
        self.displayFilteredPostsWithProviders(providers, accountFilters: nil)
    }
    
    public func displayFilteredPostsWithProviders(providers: Set<ADSSocialFeedProvider>, accountFilters: [ADSSocialFeedAccount : [String]]?) {
        // Reset scroll position
        // See: http://stackoverflow.com/a/9450345/699963
        self.contentOffset = CGPointMake(0, -self.contentInset.top)
        
        self.isLoadingFeed = true
        
        // Fix for scrollViewDidScroll triggered programmatically issue
        // See: http://stackoverflow.com/a/17856354/699963
        self.delegate = nil
        
        self.providerFilterList = providers
        
        self.displayedPostViews.removeAll()
        self.filteredPostViews.removeAll()
        
        var filteredPostViews = Array<PostViewProtocol>()
        
        for provider in providers {
            
            postViewLoop: for var i: Int = 0; i < self.postViews.count; i++ {
                let postView = self.postViews[i]
                
                if postView.provider == provider {
                    
                    if let accountFilters = accountFilters {
                        switch postView.provider {
                        case ADSSocialFeedProvider.Youtube:
                            if let youtubePlaylistItem = postView.postData as? YoutubeVideo {
                                
                                let playlistTitle = youtubePlaylistItem.playlist.title
                                
                                for account in accountFilters.keys {
//                                    if let youtubeChannel = account.dataPayload as? YoutubeChannel {
                                    if let _ = account.dataPayload as? YoutubeChannel {
                                        let youtubeFilters = accountFilters[account]
                                        
                                        if youtubeFilters?.contains(playlistTitle) == false {
                                            continue postViewLoop
                                        }
                                    }
                                }
                            }
                        default:
                            break
                        }
                    }
                    
                    filteredPostViews.append(postView)
                }
                
                (postView as! UIView).center = self.center
            }
        }
        
        filteredPostViews.sortInPlace({ $0.postData.createdAtDate.compare($1.postData.createdAtDate) == NSComparisonResult.OrderedDescending })
        self.filteredPostViews = filteredPostViews
        self.displayedPostViews.removeAll()
        self.loadNextPosts(10, block: nil)
        self.displayPosts()
        
        self.isLoadingFeed = false
    }
    
    public func youtubePlaylistTitlesForAccount(account: ADSSocialFeedAccount) -> [String]? {
        if let youtubeChannel = account.dataPayload as? YoutubeChannel {
            var playlistTitles = [String]()
            
            for playlist in youtubeChannel.playlists {
                playlistTitles.append(playlist.title)
            }
            
            // Stand-alone playlist support
            for playlist in ADSSocialFeed.sYoutubePlaylists {
                playlistTitles.append(playlist.title)
            }
            // Stand-alone playlist support
            
            return playlistTitles
        }
        return nil
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
