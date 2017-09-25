//
//  PostViewProtocol.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 15/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

/// An abstraction of a view that displays the contents of a post.
protocol PostViewProtocol: class {
    
    /// The social platform provider for the post.
    var provider: ADSSocialFeedProvider { get }
    
    /// The content of the post.
    var postData: PostProtocol { get }
    
    /// Reloads the view to display updated post content.
    func refreshView()
}
