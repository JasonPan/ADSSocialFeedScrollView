//
//  IntegratedSocialFeedPostViewProtocol.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 15/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

protocol IntegratedSocialFeedPostViewProtocol: class {
    var provider: ADSSocialFeedProvider { get }
    var postData: IntegratedSocialFeedPostProtocol { get }
}
