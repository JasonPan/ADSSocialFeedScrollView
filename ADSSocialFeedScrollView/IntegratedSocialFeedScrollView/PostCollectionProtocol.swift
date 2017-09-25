//
//  PostCollectionProtocol.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 26/09/2017.
//  Copyright © 2017 ANT Development Studios. All rights reserved.
//

import Foundation

/// An abstraction of a collection of posts.
protocol PostCollectionProtocol {
    
    /// The posts in this collection.
    var postItems: [PostProtocol]? { get }
    
}
