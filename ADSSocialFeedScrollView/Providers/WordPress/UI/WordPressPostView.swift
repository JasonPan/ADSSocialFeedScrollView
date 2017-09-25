//
//  WordPressPostView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 7/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class WordPressPostView: ADSFeedPostView, PostViewProtocol, UITextViewDelegate {
    
    private let BASIC_POST_HEIGHT       : CGFloat = 56 - 23
    private let BASIC_IMAGE_POST_HEIGHT : CGFloat = 61 - 23
    
    var post                            : WordPressPost!
    var readPostAction                  : ((NSURL) -> Void)!
    
    //*********************************************************************************************************
    // MARK: - Interface Builder Objects
    //*********************************************************************************************************
    
    @IBOutlet weak var postTitleLabel                               : UILabel!
    @IBOutlet weak var postCreationDateLabel                        : UILabel!
    @IBOutlet weak var postMessageTextView                          : LinkTextView!
    @IBOutlet weak var postPhotoImageView                           : ADSActivityIndicatorImageView!//UIImageView!
    
    @IBOutlet private weak var _postTitleLabelHeightConstraint      : NSLayoutConstraint!
    @IBOutlet private weak var _postMessageTextViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet private weak var _postImageViewHeightConstraint       : NSLayoutConstraint!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    override func initialize() {
        super.initialize()
        
        self.clipsToBounds = true
        self.postMessageTextView.clipsToBounds = true
        
        self.postMessageTextView.scrollEnabled = false
        
        self.postCreationDateLabel.textColor = UIColor(red: 145/255, green: 151/255, blue: 163/255, alpha: 1.0)
        self.postMessageTextView.textColor = UIColor(red: 20/255, green: 24/255, blue: 35/255, alpha: 1.0)
        
        self.postMessageTextView.selectable = false
        self.postMessageTextView.font = UIFont.systemFontOfSize(14.0) //TODO: Investigate Apple bug??
        
        if debugColours { self.postMessageTextView.backgroundColor = UIColor.redColor() }
        
        //        self.refreshView()
        
        self.postMessageTextView.delegate = self
        self.postMessageTextView.selectable = true
        self.postMessageTextView.delaysContentTouches = false
        
        self.performSelector(#selector(self.linkSelectionFix), withObject: nil, afterDelay: 0)
        
//        self.postPhotoImageView.beginRefreshing()
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            self.post.retrieveImageSourceURLForPost(self.post, completionHandler: {
//                if self.post.image == nil {
//                    self.post.mediaURLString = nil
//                }
//                self.refreshView()
//                self.postPhotoImageView.endRefreshing()
//            })
//        })
    }
    
    func linkSelectionFix() {
        
        if let textViewGestureRecognizers = self.postMessageTextView.gestureRecognizers {
            var mutableArrayOfGestureRecognizers = [UIGestureRecognizer]()
            for gestureRecognizer in textViewGestureRecognizers {
                if !gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer.self) {
                    mutableArrayOfGestureRecognizers.append(gestureRecognizer)
                } else {
                    let longPressGestureRecognizer = gestureRecognizer as! UILongPressGestureRecognizer
                    if longPressGestureRecognizer.minimumPressDuration < 0.3 {
                        mutableArrayOfGestureRecognizers.append(gestureRecognizer)
                    }
                }
            }
            self.postMessageTextView.gestureRecognizers = mutableArrayOfGestureRecognizers;
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, post: WordPressPost, readMoreAction: (NSURL) -> Void) {
        self.post = post
        self.readPostAction = readMoreAction
        super.init(frame: frame)
    }
    
    //*********************************************************************************************************
    // MARK: - PostViewProtocol
    //*********************************************************************************************************
    
    var provider: ADSSocialFeedProvider {
        return ADSSocialFeedProvider.WordPress
    }
    
    var postData: PostProtocol {
        return self.post
    }
    
    //*********************************************************************************************************
    // MARK: - Interface handling
    //*********************************************************************************************************
    
    func refreshView() {
        
        self.postTitleLabel.text = self.post.title
//        if currentPost.image != nil { postView.postPhotoImageView.downloadedFrom(link: currentPost.image, contentMode: .ScaleAspectFill, handler: nil) }
        
        if let creationDate = self.post.publishDate {
            self.postCreationDateLabel.text = ADSSocialDateFormatter.stringFromDate(creationDate, provider: .WordPress)
        }
//        postView.postMessageTextView.text = currentPost.excerptText
        
        
        self.postTitleLabel.sizeToFit()
        self.postTitleLabel.layoutIfNeeded() //TODO: investigate. This line is essential to take into weird line break issues
        let height = self.postTitleLabel.sizeThatFits(CGSizeMake(self.postTitleLabel.frame.size.width, CGFloat.max)).height
        self._postTitleLabelHeightConstraint.constant = height
        
        self.layoutIfNeeded()
        
        if self.post.excerptText != nil {
            
            let attributedExcerptText = NSMutableAttributedString(string: self.post.excerptText)
            
            var checkString = self.post.excerptText as NSString
            while checkString.length > 0 {
                let range = checkString.rangeOfString(" … Read More")
                
                if range.location != NSNotFound {
                    let actualRange = NSMakeRange(range.location + 3, range.length - 3)
                    
                    attributedExcerptText.addAttribute(NSLinkAttributeName, value: self.post.link.absoluteString, range: actualRange)
                    
                    checkString = checkString.substringFromIndex(actualRange.location + actualRange.length)
                }else {
                    checkString = ""
                }
            }
            
            attributedExcerptText.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14.0), range: NSMakeRange(0, attributedExcerptText.length))
            self.postMessageTextView.attributedText = attributedExcerptText
            
            self.postMessageTextView.sizeToFit()
            self.postMessageTextView.layoutIfNeeded() //TODO: investigate. This line is essential to take into weird line break issues
            let height = self.postMessageTextView.sizeThatFits(CGSizeMake(self.postMessageTextView.frame.size.width, CGFloat.max)).height
            self.postMessageTextView.contentSize.height = height
            self._postMessageTextViewHeightConstraint.constant = height
            
            self.layoutIfNeeded()
            
        }else {
            
            self._postMessageTextViewHeightConstraint.constant = 0
            self.layoutIfNeeded()
            
        }
        
        if self.post.image != nil {
            if self.postPhotoImageView.image == nil {
                self.postPhotoImageView.downloadedFrom(link: self.post.image!, contentMode: UIViewContentMode.ScaleAspectFill, handler: {
                    
                    if self.postPhotoImageView.image != nil { //TODO : verify effectivess - for safety
                        self._postImageViewHeightConstraint.constant = self.postPhotoImageView.heightFromScreenWidth()
                    }else {
                        self._postImageViewHeightConstraint.constant = 0
                    }
                    
                    self.layoutIfNeeded()
                    self.refreshView()
                })
            }
            
            self.setPostHeight(BASIC_IMAGE_POST_HEIGHT + self._postTitleLabelHeightConstraint.constant + self._postMessageTextViewHeightConstraint.constant + self._postImageViewHeightConstraint.constant)
        }else {
//            self.setPostHeight(BASIC_POST_HEIGHT + self._postTitleLabelHeightConstraint.constant + self._postMessageTextViewHeightConstraint.constant)
            
            if self.post.mediaURLString != nil {
                
                self.postPhotoImageView.beginRefreshing()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.post.retrieveImageSourceURLForPost(self.post, completionHandler: {
                        if self.post.image == nil {
                            self.post.mediaURLString = nil
                        }
                        self.refreshView()
                        self.postPhotoImageView.endRefreshing()
                    })
                })
                
//                self.setPostHeight(BASIC_POST_HEIGHT + self._postTitleLabelHeightConstraint.constant + self._postMessageTextViewHeightConstraint.constant + self.bounds.size.height)
//                self.setPostHeight(BASIC_POST_HEIGHT + self._postTitleLabelHeightConstraint.constant + self._postMessageTextViewHeightConstraint.constant + 375) // <- TODO: Address 'magic' number
                
//                self._postImageViewHeightConstraint.constant = 375 // <- TODO: Address 'magic' number
                self._postImageViewHeightConstraint.constant = self.postPhotoImageView.bounds.width
                self.setPostHeight(BASIC_IMAGE_POST_HEIGHT + self._postTitleLabelHeightConstraint.constant + self._postMessageTextViewHeightConstraint.constant + self._postImageViewHeightConstraint.constant)
                
            }else {
                self.setPostHeight(BASIC_POST_HEIGHT + self._postTitleLabelHeightConstraint.constant + self._postMessageTextViewHeightConstraint.constant)
            }
            
        }
        
        self.layoutIfNeeded()
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    //*********************************************************************************************************
    // MARK: - UITextViewDelegate
    //*********************************************************************************************************
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if (URL.absoluteString == self.post.link.absoluteString) {
            self.readPostAction(self.post.link)
        }
        return false
    }
    
}
