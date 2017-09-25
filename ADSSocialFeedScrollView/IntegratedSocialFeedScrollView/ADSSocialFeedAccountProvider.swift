//
//  ADSSocialFeedAccountProvider.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 1/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

class ADSSocialFeedAccountProvider {
    // Implement nothing.
}

class ADSSocialFeedFacebookAccountProvider: ADSSocialFeedAccountProvider {
    // Implement nothing.
    internal static var authKey: String!
}

class ADSSocialFeedYoutubeAccountProvider: ADSSocialFeedAccountProvider {
    // Implement nothing.
    internal static var authKey: String!
}

class ADSSocialFeedInstagramAccountProvider: ADSSocialFeedAccountProvider {
    // Implement nothing.
    internal static var authKey: String!
    internal static var clientId: String!
    internal static var redirectURI: String!
}

class ADSSocialFeedWordPressAccountProvider: ADSSocialFeedAccountProvider {
    // Implement nothing.
    internal static var displayPostAction: ((NSURL) -> Void)!
}

class ADSSocialFeedSoundCloudAccountProvider: ADSSocialFeedAccountProvider {
    // Implement nothing.
    internal static var clientId: String!
}