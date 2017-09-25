//
//  FacebookPost.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 12/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

class FacebookPost: IntegratedSocialFeedPostProtocol {
    
    private var internal_createdTime: NSDate?
    private var internal_image: UIImage?
    
    private(set) var createdTime    : String
    private(set) var id             : String
    private(set) var message        : String?
    private(set) var image          : String?
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(id: String, createdTime: String, message: String?, image: String?) {
        self.id = id
        self.createdTime = createdTime
        self.message = message
        self.image = image
        
        self.internal_createdTime = ADSSocialDateFormatter.dateFromString(self.createdTime, provider: .Facebook)
        
        //TODO: Investigate if this can actually occur. Videos?
        if message == nil && image == nil {
            NSLog("[ADSSocialFeedScrollView][Facebook] An error occurred while initializing FacebookPost: both message & image are nil");
        }
    }
    
    //*********************************************************************************************************
    // MARK: - Description //TODO: Remove?
    //*********************************************************************************************************
    
    var description: String {
        get {
            let descriptionDict = NSMutableDictionary()
            descriptionDict["id"] = self.id
            descriptionDict["createdTime"] = self.createdTime
            descriptionDict["message"] = self.message
            descriptionDict["image"] = self.image
            
            return "\(descriptionDict)\n"
        }
    }
    
    //*********************************************************************************************************
    // MARK: - IntegratedSocialFeedPostProtocol
    //*********************************************************************************************************
    
    var createdAtDate: NSDate! {
        return self.internal_createdTime
    }
}
