//
//  ADSSocialFeedProviderProtocol.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 1/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

public func ==(lhs: ADSSocialFeedAccount, rhs: ADSSocialFeedAccount) -> Bool {
    return lhs.id == rhs.id
}

public class ADSSocialFeedAccount: Hashable {
    
    public var hashValue: Int {
        return self.id.hashValue
    }
    
    var id: String
    var provider: ADSSocialFeedProvider
    var dataPayload: AnyObject! //TODO: ADSSocialAccount
    
    public class func accountForId(id: String, provider: ADSSocialFeedProvider) -> ADSSocialFeedAccount {
        let account = ADSSocialFeedAccount(id: id, provider: provider)
        
        for existingAccount in ADSSocialFeed.accounts {
            if account.id == existingAccount.id && account.provider == existingAccount.provider {
                return existingAccount
            }
        }
        
        return account
    }
    
    public init(id: String, provider: ADSSocialFeedProvider) {
        self.id = id
        self.provider = provider
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            switch self.provider {
            case ADSSocialFeedProvider.Facebook:
                self.dataPayload = FacebookPage(id: self.id)
            case ADSSocialFeedProvider.Youtube:
                self.dataPayload = YoutubeChannel(id: self.id)
            case ADSSocialFeedProvider.Instagram:
                self.dataPayload = InstagramUser(id: self.id)
            case ADSSocialFeedProvider.WordPress:
                self.dataPayload = WordPressPostCollection(baseURLString: self.id)
            case ADSSocialFeedProvider.SoundCloud:
                self.dataPayload = SoundCloudUser(id: self.id)
            }
        })
        
        if let page = self.dataPayload as? FacebookPage {
            repeat {} while page.name == nil
        }
    }
}
