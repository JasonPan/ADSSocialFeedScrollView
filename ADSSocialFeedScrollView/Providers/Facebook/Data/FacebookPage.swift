//
//  FacebookPage.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 13/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FacebookPage: PostCollectionProtocol {
    
    private(set) var id                 : String!
    private(set) var name               : String!
    private(set) var profilePhotoURL    : String!
    private(set) var coverPhotoURL      : String!
    
    var feed            : Array<FacebookPost>!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(id: String) {
        self.id = id
    }
    
    //*********************************************************************************************************
    // MARK: - Data retrievers
    //*********************************************************************************************************
    
    func fetchProfileInfoInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        //SIDENOTE: Facebook iOS SDK requires requests to be sent from main queue?? Bug?
        dispatch_async(dispatch_get_main_queue(), {
            FBSDKGraphRequest.init(graphPath: self.id, parameters: ["access_token": ADSSocialFeedFacebookAccountProvider.authKey, "fields": "name, picture, cover"]).startWithCompletionHandler({
                connection, result, error in
                if error == nil {
                    if let dictionary = result as? Dictionary<String, AnyObject> {
                        let name = dictionary["name"] as? String
                        let picture = dictionary["picture"]?["data"]??["url"] as? String
                        let cover = dictionary["cover"]?["source"] as? String
                        
                        self.name = name
                        self.profilePhotoURL = picture
                        self.coverPhotoURL = cover
                    }
                    
                }else {
                    NSLog("[ADSSocialFeedScrollView][Facebook] An error occurred while fetching profile info: \(error?.description)");
                }
                
                self.fetchPostsInBackgroundWithCompletionHandler(block)
                
            })
        })
    }
    
    private func fetchPostsInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        //SIDENOTE: Facebook iOS SDK requires requests to be sent from main queue?? Bug?
        dispatch_async(dispatch_get_main_queue(), {
            FBSDKGraphRequest.init(graphPath: self.id + "/posts", parameters: ["access_token": ADSSocialFeedFacebookAccountProvider.authKey, "fields": "created_time, id, message, picture, attachments"]).startWithCompletionHandler({
                connection, result, error in
                
                if error == nil {
                    
                    let JSON_data: Dictionary<String, AnyObject>? = result as? Dictionary<String, AnyObject>
                    
                    guard JSON_data != nil else {
                        return
                    }
                    
                    if let feedData_JSON: Array<Dictionary<String, AnyObject>> = JSON_data?["data"] as? Array<Dictionary<String, AnyObject>> {
                        
                        var feedArray: Array<FacebookPost> = Array<FacebookPost>()
                        
                        for dictionary in feedData_JSON {
                            let id = dictionary["id"] as? String
                            let created_time = dictionary["created_time"] as? String
                            let message = dictionary["message"] as? String
                            var picture = dictionary["picture"] as? String
                            
                            if let attachments = dictionary["attachments"] as? NSDictionary {
                                if let data = attachments["data"] as? NSArray {
                                    if let media = data[0]["media"] as? NSDictionary {
                                        if let image = media["image"] {
                                            if let src = image["src"] as? String {
                                                picture = src
                                            }
                                        }
                                    }
                                }
                            }
                            
                            let facebookPost: FacebookPost = FacebookPost(id: id!, createdTime: created_time!, message: message, image: picture, owner: self)
                            feedArray.append(facebookPost)
                        }
                        
                        self.feed = feedArray
                    }
                }else {
                    NSLog("[ADSSocialFeedScrollView][Facebook] An error occurred while fetching posts: \(error?.description)");
                    self.feed = Array<FacebookPost>()
                }
                
                block?()
            })
        })
    }
    
    //*********************************************************************************************************
    // MARK: - PostCollectionProtocol
    //*********************************************************************************************************
    
    var postItems: [PostProtocol]? {
        // See: https://stackoverflow.com/a/30101004/699963
        return self.feed.map({ $0 as PostProtocol })
    }

}
