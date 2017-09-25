//
//  FacebookPostView.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 15/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class FacebookPostView: ADSFeedPostView, UITextViewDelegate, PostViewProtocol {
    
    private let CREATION_DATE_TEXT_COLOUR       : UIColor = UIColor(red: 145/255, green: 151/255, blue: 163/255, alpha: 1.0)
    private let POST_MESSAGE_TEXT_COLOUR        : UIColor = UIColor(red: 20/255, green: 24/255, blue: 35/255, alpha: 1.0)
    
    private let BASIC_POST_HEIGHT               : CGFloat = 67
    private let BASIC_IMAGE_POST_HEIGHT         : CGFloat = 72
    
    var post                                    : FacebookPost!
    
    //*********************************************************************************************************
    // MARK: - Interface Builder objects
    //*********************************************************************************************************
    
    @IBOutlet weak var profilePhotoImageView                        : UIImageView!
    @IBOutlet weak var pageNameLabel                                : UILabel!
    @IBOutlet weak var postCreationDateLabel                        : UILabel!
    @IBOutlet weak var postMessageTextView                          : UITextView!
    @IBOutlet weak var postPhotoImageView                           : UIImageView!
    
    @IBOutlet private weak var _postMessageTextViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet private weak var _postImageViewHeightConstraint       : NSLayoutConstraint!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    override func initialize() {
        super.initialize()
        
        self.clipsToBounds = true
        self.postMessageTextView.clipsToBounds = true
        
        self.postMessageTextView.delegate = self
        self.postMessageTextView.scrollEnabled = false
        
        self.postCreationDateLabel.textColor = CREATION_DATE_TEXT_COLOUR
        self.postMessageTextView.textColor = POST_MESSAGE_TEXT_COLOUR
        
        self.postMessageTextView.selectable = false
        self.postMessageTextView.font = UIFont.systemFontOfSize(14.0) //TODO: Investigate Apple bug??
        
        self.postMessageTextView.textStorage
        
        if debugColours { self.postMessageTextView.backgroundColor = UIColor.redColor() }
        
        //        self.refreshView()
        
        self.postPhotoImageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, post: FacebookPost) {
        self.post = post
        super.init(frame: frame)
    }
    
    //*********************************************************************************************************
    // MARK: - PostViewProtocol
    //*********************************************************************************************************
    
    var provider: ADSSocialFeedProvider {
        return ADSSocialFeedProvider.Facebook
    }
    
    var postData: PostProtocol {
        return self.post
    }
    
    //*********************************************************************************************************
    // MARK: - Interface handlers
    //*********************************************************************************************************
    
    func refreshView() {
        
        self.pageNameLabel.text = self.post.owner.name
        
        // Attempt to download the profile picture of the post's owner.
        if self.post.owner.profilePhotoURL != nil {
            self.profilePhotoImageView.downloadedFrom(link: self.post.owner.profilePhotoURL, contentMode: .ScaleAspectFill, handler: nil)
        }
        
        let creationDate = self.post.createdTime
        self.postCreationDateLabel.text = ADSSocialDateFormatter.stringFromString(creationDate, provider: .Facebook)
        self.postMessageTextView.text = self.post.message
        
        if self.post.message != nil {
            
            self.postMessageTextView.sizeToFit()
            self.postMessageTextView.layoutIfNeeded() //TODO: investigate. This line is essential to take into weird line break issues
            let height = self.postMessageTextView.sizeThatFits(CGSizeMake(self.postMessageTextView.frame.size.width, CGFloat.max)).height
            self.postMessageTextView.contentSize.height = height
            self._postMessageTextViewHeightConstraint.constant = height
            
//            self.layoutIfNeeded()
            
        }else {
            
            self._postMessageTextViewHeightConstraint.constant = 0
//            self.layoutIfNeeded()
            
        }
        
        if self.post.image != nil {
            if self.postPhotoImageView.image == nil {
                self.postPhotoImageView.downloadedFrom(link: self.post.image!, contentMode: UIViewContentMode.ScaleAspectFit, handler: {
                    
                    if self.postPhotoImageView.image != nil { //TODO : verify effectivess - for safety
                        self._postImageViewHeightConstraint.constant = self.postPhotoImageView.heightFromScreenWidth()
                    }else {
                        self._postImageViewHeightConstraint.constant = 0
                    }
                    
//                    self.layoutIfNeeded()
                    self.refreshView()
                })
            }
            
            self.setPostHeight(BASIC_IMAGE_POST_HEIGHT + self._postMessageTextViewHeightConstraint.constant + self._postImageViewHeightConstraint.constant)
        }else {
            self.setPostHeight(BASIC_POST_HEIGHT + self._postMessageTextViewHeightConstraint.constant)
        }
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
}
