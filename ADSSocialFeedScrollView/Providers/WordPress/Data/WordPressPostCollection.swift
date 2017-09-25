//
//  WordPressPostCollection.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 7/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

class WordPressPostCollection {
    
    private var baseURLString: String
    var posts: [WordPressPost]!
    
    private var postsDataArray: [AnyObject]? = [AnyObject]()
    private var postsArray: [Dictionary<String, AnyObject>]! = [Dictionary<String, AnyObject>]()
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString + "/wp-json/wp/v2/posts?per_page=100"
    }
    
    //*********************************************************************************************************
    // MARK: - Data retrievers
    //*********************************************************************************************************
    
    func fetchPostsInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        
        var imageFetchCount = 0
        
        self.retreivePostsWithCompletionHandler({
            postsArray in
            
            var loadedPosts = [WordPressPost]()
            
            for post in postsArray {
                let title: String = post["title"]!["rendered"]!! as! String
                let excerpt: String = post["excerpt"]!["rendered"]!! as! String
                let link: String = post["link"]! as! String
                
                let publishDateString = post["date_gmt"]! as! String
                let publishDate = ADSSocialDateFormatter.dateFromString(publishDateString, provider: ADSSocialFeedProvider.WordPress)!
                
//                let mediaURLString: String = post["_links"]!["https://api.w.org/featuredmedia"]!![0]!["href"]!! as! String
//                let mediaURLString: String? = post["_links"]?["https://api.w.org/featuredmedia"]??[0]?["href"] as? String
                let mediaURLString: String? = post["_links"]?["wp:featuredmedia"]??[0]?["href"] as? String
                
                print("Post ID: \(post["id"]!)")
                print(excerpt)
                
                let wordPressPost: WordPressPost = WordPressPost(title: title, link: link, excerptText: excerpt, publishDate: publishDate, mediaURLString: mediaURLString)
                loadedPosts.append(wordPressPost)
                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.retrieveImageSourceURLForPost(wordPressPost, completionHandler: {
                        imageFetchCount++
                        
                        if imageFetchCount >= self.posts?.count {
                            block?()
                        }
                    })
//                })
                
            }
            
            self.posts = loadedPosts
            
            print("Found \(self.posts.count) WordPress posts")
            
////            print("test123: \(self.posts.count)")
////            print("test456: \(imageFetchCount)")
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                repeat {} while self.posts == nil
//                
////                var loadCount = 0
////                
////                for post in self.posts {
////                    print("get")
////                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
////                        self.retrieveImageSourceURLForPost(post, completionHandler: {
////                            loadCount++
////                        })
////                    })
////                }
//                
//                repeat {} while imageFetchCount < self.posts.count
//                dispatch_async(dispatch_get_main_queue(), {
//                    block?()
//                })
//            })
            
            
        })
    }
    
    private func retrieveImageSourceURLForPost(post: WordPressPost, completionHandler: () -> Void) {
//        if let mediaURLString = post.mediaURLString, requestURL = NSURL(string: mediaURLString) {
//            performGetRequest(requestURL, completion: {
//                data, HTTPStatusCode, error in
//                
//                let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
//                
//                var str = jsonString.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: jsonString.rangeOfString(jsonString))
//                str = str.stringByDecodingHTMLEntities
//                
//                
//                let newStrippedData = str.dataUsingEncoding(NSUTF8StringEncoding)
//                do {
//                    let JSON = try NSJSONSerialization.JSONObjectWithData(newStrippedData!, options: NSJSONReadingOptions(rawValue: 0))
//                    
//                    if let JSON = JSON as? NSDictionary {
//                        let imageURLString = JSON["media_details"]?["sizes"]??["medium"]??["source_url"]
////                        let imageURLString = JSON["media_details"]?["sizes"]??["large"]??["source_url"]
//                        print("imageURLString: \(imageURLString)")
//                        post.image = imageURLString as? String
//                        
//                        completionHandler()
//                    }else {
//                        print("JSON PARSE FAIL: \(JSON)")
//                        completionHandler()
//                    }
//                }catch {
//                    self.retrieveImageSourceURLForPost(post, completionHandler: completionHandler)
//                }
//            })
//            
//        }else {
//            // TODO: Add handler
//            
//            print("retrieving image for url failed: \(post.mediaURLString)")
//            completionHandler()
//        }
        completionHandler()
    }
    
    private func retreivePostsWithCompletionHandler(block: (([Dictionary<String, AnyObject>]) -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let fetchCompletionBlock = {
                self.postsArray = [Dictionary<String, AnyObject>]()
                
                if self.postsDataArray != nil {
                    for postData in self.postsDataArray! {
                        self.postsArray.append(postData as! Dictionary<String, AnyObject>)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    block?(self.postsArray)
                })
            }
            
            if self.postsDataArray?.count == 0 || self.postsDataArray == nil {
                self.postsDataArray = [AnyObject]()
                self.retreivePostsDataArrayWithCompletionHandler({
                    jsonArray in
                    self.postsDataArray = jsonArray
                    
                    fetchCompletionBlock()
                })
            }else {
                fetchCompletionBlock()
            }
        })
    }
    
    private func retreivePostsDataArrayWithCompletionHandler(block: ([AnyObject]?) -> Void) {
        requestWithHTTPMethod("GET", apiKey: nil, shouldUseBase64Encoding: true, params: nil, url: self.baseURLString, postCompleted: {
            succeeded, JSON, jsonString in
            
            if let jsonString = jsonString {
                var str = jsonString.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: jsonString.rangeOfString(jsonString))
                str = str.stringByDecodingHTMLEntities
                
                let newStrippedData = str.dataUsingEncoding(NSUTF8StringEncoding)
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(newStrippedData!, options: NSJSONReadingOptions(rawValue: 0))
                    
                    if let JSON = JSON as? [AnyObject] {
                        block(JSON)
                    }
                }catch {
                    block(nil)
                }
                
            }else {
                block(nil)
            }
        })
    }
}
