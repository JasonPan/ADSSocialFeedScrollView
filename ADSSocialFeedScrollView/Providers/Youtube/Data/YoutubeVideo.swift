//
//  YoutubeVideo.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 14/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

class YoutubeVideo: IntegratedSocialFeedPostProtocol {
    
    private(set) var playlist: YoutubePlaylist!
    
    var id: String!
    var title: String!
    var description: String!
    var thumbnailImageURL: String!
    var publishedAt: String!
    var publishedAt_DATE: NSDate!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(playlist: YoutubePlaylist, videoId: String, title: String!, description: String!, thumbnailImageURL: String!, publishedAt: String!) {
        self.playlist = playlist
        
        self.id = videoId
        self.title = title
        self.description = description
        self.thumbnailImageURL = thumbnailImageURL
        self.publishedAt = publishedAt
        
        self.publishedAt_DATE = ADSSocialDateFormatter.dateFromString(self.publishedAt, provider: .Youtube)
    }
    
    //*********************************************************************************************************
    // MARK: - IntegratedSocialFeedPostProtocol
    //*********************************************************************************************************
    
    var createdAtDate: NSDate! {
        return self.publishedAt_DATE
    }
    
}
