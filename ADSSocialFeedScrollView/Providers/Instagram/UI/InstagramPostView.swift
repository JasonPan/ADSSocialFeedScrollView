//
//  InstagramPostView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 18/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class InstagramPostView: ADSFeedPostView, PostViewProtocol {
    
    private let BASIC_POST_HEIGHT: CGFloat = 101//71
    private let HIGHLIGHTED_TEXT_COLOUR: UIColor = UIColor(red: 18/255, green: 86/255, blue: 136/255, alpha: 1.0)
    private let GREY_TEXT_COLOUR: UIColor = UIColor(red: 165/255, green: 167/255, blue: 170/255, alpha: 1.0)
    
    var post: InstagramPost!
    
    var showFullCaption: Bool = false
    
    //*********************************************************************************************************
    // MARK: - Interface Builder Objects
    //*********************************************************************************************************
    
    @IBOutlet private weak var _postImageViewHeightConstraint   : NSLayoutConstraint!
    @IBOutlet private weak var _postCommentsTextViewHeightConstraint   : NSLayoutConstraint!
    
    @IBOutlet weak var postLikesCountLabel                      : UILabel!
    @IBOutlet weak var postCommentsTextView                     : UITextView!
    
    @IBOutlet weak var postPhotoImageView                       : UIImageView!
    @IBOutlet weak var postProfilePhotoImageView                : UIImageView!
    @IBOutlet weak var postProfileUserNameLabel                 : UILabel!
    @IBOutlet weak var postPublishDateLabel                     : UILabel!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    override func initialize() {
        super.initialize()
        
        self.setPostHeight(BASIC_POST_HEIGHT)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.clipsToBounds = true
        self.postPhotoImageView.clipsToBounds = true
        
        self.postProfileUserNameLabel.textColor = HIGHLIGHTED_TEXT_COLOUR
        self.postPublishDateLabel.textColor = GREY_TEXT_COLOUR
        
        self.postProfilePhotoImageView.layer.masksToBounds = true
        self.postProfilePhotoImageView.layer.cornerRadius = self.postProfilePhotoImageView.bounds.size.width / 2
        
        self.postProfileUserNameLabel.text = self.post.publishedBy?.username
        self.postProfilePhotoImageView.downloadedFrom(link: self.post.publishedBy.profilePictureURL.absoluteString, contentMode: .ScaleAspectFit, handler: nil)
        self.postPublishDateLabel.text = ADSSocialDateFormatter.stringFromDate(self.post.publishDate, provider: .Instagram)
//        self.postPhotoImageView.downloadedFrom(link: self.post.imageURL.absoluteString, contentMode: .ScaleAspectFit, handler: nil)
        self.postPhotoImageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        self.postLikesCountLabel.text = "♥ \(self.post.likesCount) likes"
        self.postLikesCountLabel.textColor = HIGHLIGHTED_TEXT_COLOUR
        self.postCommentsTextView.text = self.post.caption
        
        self.postCommentsTextView.alwaysBounceVertical = false
        self.postCommentsTextView.bounces = false
        self.postCommentsTextView.scrollEnabled = false
        
        self.refreshView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, post: InstagramPost) {
        self.post = post
        super.init(frame: frame)
    }
    
    //*********************************************************************************************************
    // MARK: - PostViewProtocol
    //*********************************************************************************************************
    
    var provider: ADSSocialFeedProvider {
        return ADSSocialFeedProvider.Instagram
    }
    
    var postData: PostProtocol {
        return self.post
    }
    
    //*********************************************************************************************************
    // MARK: - Interface handling
    //*********************************************************************************************************
    
    func refreshView() {
        if self.post.caption != nil {
            
            if self.showFullCaption {
                self.postCommentsTextView.text = self.post.caption!
                self.postCommentsTextView.textContainer.maximumNumberOfLines = 0
                
                self.postCommentsTextView.sizeToFit()
                self.postCommentsTextView.layoutIfNeeded() //TODO: investigate. This line is essential to take into weird line break issues
                let height = self.postCommentsTextView.sizeThatFits(CGSizeMake(self.postCommentsTextView.frame.size.width, CGFloat.max)).height
                
                self.postCommentsTextView.contentSize.height = height
                self._postCommentsTextViewHeightConstraint.constant = height
                
                UIView.animateWithDuration(0.3, animations: {
                    self.layoutIfNeeded()
                })
            }else {
                self.postCommentsTextView.text = (self.post.caption! as NSString).stringByTruncatingToSize(CGSizeMake(self.postCommentsTextView.frame.width, 60), withFont: self.postCommentsTextView.font!) as String
                
                self.postCommentsTextView.sizeToFit()
                self.postCommentsTextView.layoutIfNeeded() //TODO: investigate. This line is essential to take into weird line break issues
                let height = self.postCommentsTextView.sizeThatFits(CGSizeMake(self.postCommentsTextView.frame.size.width, CGFloat.max)).height
                
                self.postCommentsTextView.contentSize.height = height
                self._postCommentsTextViewHeightConstraint.constant = height
                
//                self.layoutIfNeeded()
            }
            
            self.processCaption()
//
//            self.layoutIfNeeded()
            
        }else {
            
            self._postCommentsTextViewHeightConstraint.constant = 0
//            self.layoutIfNeeded()
            
        }
        
        if self.post.imageURL != nil {
            if self.postPhotoImageView.image == nil {
                self.postPhotoImageView.downloadedFrom(link: self.post.imageURL.absoluteString, contentMode: UIViewContentMode.ScaleAspectFit, handler: {
                    
                    if self.postPhotoImageView.image != nil { //TODO : verify effectivess - for safety
                        self._postImageViewHeightConstraint.constant = self.postPhotoImageView.heightFromScreenWidth()
                    }else {
                        self._postImageViewHeightConstraint.constant = 0
                    }
                    
//                    self.postPhotoImageView.layoutIfNeeded()
                    self.refreshView()
                })
            }
            
            self.setPostHeight(BASIC_POST_HEIGHT + self._postCommentsTextViewHeightConstraint.constant + self._postImageViewHeightConstraint.constant)
        }else {
            self.setPostHeight(BASIC_POST_HEIGHT + self._postCommentsTextViewHeightConstraint.constant)
        }
        
    }
    
    func processCaption() {
        guard self.postCommentsTextView.text != nil else {
            return
        }
        
        let attributedExcerptText = NSMutableAttributedString(string: self.postCommentsTextView.text!)
        
        // See: http://stackoverflow.com/a/26609085/699963
        let tags = self.postCommentsTextView.text!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " \n"))
            .filter { $0.characters.count > 1 }
            .filter { $0.hasPrefix("#") || $0.hasPrefix("@") }
        
        let checkString = self.postCommentsTextView.text! as NSString
        
        for tag in tags {
            var tag = tag
            
            var checkRange = NSMakeRange(0, checkString.length)
            
            if tag.hasSuffix(" ") {
                tag = tag.substringToIndex(tag.endIndex.advancedBy(-1))
                print(tag)
            }
            
            while checkRange.length > 0 {
                let range = checkString.rangeOfString(tag, options: NSStringCompareOptions.init(rawValue: 0), range: checkRange)
                
                if range.location != NSNotFound {
                    attributedExcerptText.addAttribute(NSForegroundColorAttributeName, value: HIGHLIGHTED_TEXT_COLOUR, range: range)
                    
                    checkRange.location = range.location + range.length
                    checkRange.length = checkString.length - (range.location + range.length)
                }else {
                    checkRange.location = NSNotFound
                    checkRange.length = 0
                }
            }
        }
        
        attributedExcerptText.addAttribute(NSFontAttributeName, value: self.postCommentsTextView.font!, range: NSMakeRange(0, attributedExcerptText.length))
        
        if self.postCommentsTextView.text.hasSuffix(ellipsis) && !self.showFullCaption {
            
            //TODO: Investigate why the following doesn't work...
//            let location1 = self.postCommentsTextView.text!.characters.count - (ellipsis.characters.count)
//            let location2 = self.postCommentsTextView.text!.characters.count - (ellipsis as NSString).rangeOfString("more").length
////            let range = NSMakeRange(location, 1)
//            
//            attributedExcerptText.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(location1, 1))
//            attributedExcerptText.addAttribute(NSForegroundColorAttributeName, value: GREY_TEXT_COLOUR, range: NSMakeRange(location2, 4))
            
            
            //TODO: Investigate solution below (for above):
            let location = (self.postCommentsTextView.text! as NSString).rangeOfString(ellipsis).location
            
            attributedExcerptText.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkTextColor(), range: NSMakeRange(location, 1))
            attributedExcerptText.addAttribute(NSForegroundColorAttributeName, value: GREY_TEXT_COLOUR, range: NSMakeRange(location + 2, 4))
        }
        
        self.postCommentsTextView.attributedText = attributedExcerptText
    }
}
