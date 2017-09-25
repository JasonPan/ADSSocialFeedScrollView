//
//  SoundCloudTrack.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 26/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation
import SwiftyJSON

class SoundCloudTrack: IntegratedSocialFeedPostProtocol {
    
    var id              : String
    var title           : String
    var stream_url      : String!
    
    var created_at      : String
    var last_modified   : String
    
    var artwork_url     : String
    var waveform_url    : String
    
    private var publishedAt_DATE: NSDate!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(dataPayload: JSON) {
        
        self.id             = dataPayload["id"].stringValue
        self.title          = dataPayload["title"].stringValue
        
        self.created_at     = dataPayload["created_at"].stringValue
        self.last_modified  = dataPayload["last_modified"].stringValue
        self.artwork_url    = dataPayload["artwork_url"].stringValue.stringByReplacingOccurrencesOfString("-large.jpg", withString: "-t300x300.jpg")
        self.waveform_url   = dataPayload["waveform_url"].stringValue
        print("check:|" + created_at)
        
        self.publishedAt_DATE = ADSSocialDateFormatter.dateFromString(self.created_at, provider: .SoundCloud)
    }
    
    //*********************************************************************************************************
    // MARK: - IntegratedSocialFeedPostProtocol
    //*********************************************************************************************************
    
    var createdAtDate: NSDate! {
        return self.publishedAt_DATE
    }
    
}
