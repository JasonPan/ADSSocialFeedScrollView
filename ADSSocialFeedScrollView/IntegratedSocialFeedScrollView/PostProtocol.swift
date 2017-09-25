//
//  PostProtocol.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 15/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

/// An abstraction of a post.
protocol PostProtocol {
    
    /// The creation date of this post. Used for sorting.
    var createdAtDate: NSDate! { get }
    
}