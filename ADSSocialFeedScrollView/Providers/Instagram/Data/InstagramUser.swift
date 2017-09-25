//
//  InstagramUser.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 18/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import InstagramKit

class InstagramUser: NSObject, PostCollectionProtocol {
    
    private let INSTAGRAM_AUTHORISATION_BASE_URL = "https://api.instagram.com/oauth/authorize/"
    
    private(set) var userId                 : String
    private(set) var username               : String! = "<null>"
    private(set) var profilePictureURL      : NSURL!
    
    var posts: [InstagramPost]!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(id: String) {
        self.userId = id
        super.init()
        
        var urlString = INSTAGRAM_AUTHORISATION_BASE_URL + "?client_id=\(ADSSocialFeedInstagramAccountProvider.clientId)"
        urlString = addParamToURLString(urlString, paramKey: "redirect_uri", paramValue: ADSSocialFeedInstagramAccountProvider.redirectURI)
        urlString = addParamToURLString(urlString, paramKey: "response_type", paramValue: "token")
        
        let url = NSURL(string: urlString)!
        
        self.authenticationRequest(url, completion: {
            data, statusCode, error in
            if ADSSocialFeedInstagramAccountProvider.authKey == nil {
                print("InstagramUser: Authentication failed with status code: \(statusCode).")
                if error != nil { print("error: \(error?.description)") }
            }
        })
    }
    
    //*********************************************************************************************************
    // MARK: - Data retrievers
    //*********************************************************************************************************
    
    func fetchProfileInfoInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        dispatch_async(dispatch_get_main_queue(), {
            repeat {} while ADSSocialFeedInstagramAccountProvider.authKey == nil
            
            let engine: InstagramEngine = InstagramEngine.sharedEngine()
            engine.accessToken = ADSSocialFeedInstagramAccountProvider.authKey
            
            engine.getUserDetails(self.userId, withSuccess: {
                user in
                
                self.username = user.username
                self.profilePictureURL = user.profilePictureURL
                
                }, failure: {
                    error, serverStatusCode in
                    
                    print("[ADSSocialFeedScrollView][Instagram]: An error occured with server status code \(serverStatusCode): \(error)")
            })
            
            self.fetchPostsInBackgroundWithCompletionHandler(block)
        })
    }
    
    private func fetchPostsInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        dispatch_async(dispatch_get_main_queue(), {
            repeat {} while ADSSocialFeedInstagramAccountProvider.authKey == nil
            
            let engine: InstagramEngine = InstagramEngine.sharedEngine()
            engine.accessToken = ADSSocialFeedInstagramAccountProvider.authKey
            
            engine.getMediaForUser(self.userId, withSuccess:  {
                media, paginationInfo in
                
                self.posts = Array<InstagramPost>()
                
                for mediaObject in media {
                    let post: InstagramPost = InstagramPost(id: mediaObject.Id, likesCount: mediaObject.likesCount, caption: mediaObject.caption?.text, imageURL: mediaObject.standardResolutionImageURL, publishDate: mediaObject.createdDate)
                    post.publishedBy = self
                    
                    self.posts.append(post)
                    
//                    self.loadCommentsForMediaId(post.id, completionHandler: nil)
                }
                
                block?()
                
                }, failure: {
                    error, serverStatusCode in
                    
                    print("[ADSSocialFeedScrollView][Instagram]: An error occured with server status code \(serverStatusCode): \(error)")
                    block?()
            })
        })
    }
    
    private func loadCommentsForMediaId(mediaId: String, completionHandler: (() -> Void)?) {
        dispatch_async(dispatch_get_main_queue(), {
            repeat {} while ADSSocialFeedInstagramAccountProvider.authKey == nil
            
            let engine: InstagramEngine = InstagramEngine.sharedEngine()
            engine.accessToken = ADSSocialFeedInstagramAccountProvider.authKey
            
            engine.getCommentsOnMedia(mediaId, withSuccess: {
                comments, paginationInfo in
                
                for comment in comments {
                    print("Comment: \(comment.text)")
                }
                print("-----------------")
//                print(comments)
                
                if completionHandler != nil { completionHandler!() }
                
                }, failure: nil)
        })
    }
    
    //*********************************************************************************************************
    // MARK: - PostCollectionProtocol
    //*********************************************************************************************************
    
    var postItems: [PostProtocol]? {
        // See: https://stackoverflow.com/a/30101004/699963
        return self.posts?.map({ $0 as PostProtocol })
    }
    
}

//*********************************************************************************************************
// MARK: - Instagram OAuth 2.0 Authentication Requests
//*********************************************************************************************************

extension InstagramUser: NSURLSessionTaskDelegate {
    
    func authenticationRequest(targetURL: NSURL!, completion: ((data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void)?) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard response != nil else {
                    verifyConnectionWithSuccessHandler() {
                        self.authenticationRequest(targetURL, completion: completion)
                    }
                    return
                }
                
                if completion != nil { completion!(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error) }
            })
        })
        
        ADSSocialFeed.addTask(task)
        task.resume()
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
//        print("DEBUG: requestURL \(request.URL!)")
        
        let accessTokenTag = "#access_token="
        
        if let returnString = request.URL?.absoluteString {
            if returnString.containsString(accessTokenTag) {
                let accessToken: String = returnString.componentsSeparatedByString(accessTokenTag)[1]
                print("Authenticated with accessToken: \(accessToken)")
                
                ADSSocialFeedInstagramAccountProvider.authKey = accessToken
            }
        }
        
        do {
            try InstagramEngine.sharedEngine().receivedValidAccessTokenFromURL(request.URL!)
        }catch { }
        
        //NOTE: This MUST be called in order for any subsequent redirects to occur! Duh!
        completionHandler(request)
    }
}
