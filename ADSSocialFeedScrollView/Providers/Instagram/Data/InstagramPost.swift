//
//  InstagramPost.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 18/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class InstagramPost: NSObject, IntegratedSocialFeedPostProtocol {
    
    var id: String!
    
    var likesCount: Int!
    var caption: String?
    
    var imageURL: NSURL!
    var image: UIImage!
    
    var publishDate: NSDate!
    var publishedBy: InstagramUser!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(id: String, likesCount: Int, caption: String?, imageURL: NSURL, publishDate: NSDate) {
        super.init()
        
        self.id = id
        self.likesCount = likesCount
        self.caption = caption
        self.imageURL = imageURL
        self.publishDate = publishDate
    }
    
    //*********************************************************************************************************
    // MARK: - IntegratedSocialFeedPostProtocol
    //*********************************************************************************************************
    
    var createdAtDate: NSDate! {
        return self.publishDate
    }
}
