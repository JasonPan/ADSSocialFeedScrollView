//
//  WordPressPost.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 7/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation
import StringExtensionHTML

class WordPressPost: PostProtocol {
    var title: String
    var excerptText: String!
    var link: NSURL
    
    var publishDate: NSDate!
    
    var image: String!
    var mediaURLString: String?
    
    internal var retrieveCount = 0
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(title: String, link: String, excerptText: String, publishDate: NSDate, mediaURLString: String?) {
        self.title = title
        self.link = NSURL(string: link)!
        self.excerptText = excerptText
        self.publishDate = publishDate
        self.mediaURLString = mediaURLString
        
        self.excerptText = self.excerptText.stringByReplacingOccurrencesOfString("\n", withString: "")
        
//        self.retrieveCount = 0
    }
    
    //*********************************************************************************************************
    // MARK: - PostProtocol
    //*********************************************************************************************************
    
    var createdAtDate: NSDate! {
        return self.publishDate
    }
    
    //*********************************************************************************************************
    // MARK: - Retrieve imageURLString from mediaURLString
    //
    // NOTE: - Lazy loading necessary due to delay caused by async retrieval. May change behaviour back
    // to WordPressPostCollection in future release.
    //*********************************************************************************************************
    
    internal func retrieveImageSourceURLForPost(post: WordPressPost, completionHandler: () -> Void) {
        if let mediaURLString = post.mediaURLString, requestURL = NSURL(string: mediaURLString) {
            performGetRequest(requestURL, completion: {
                data, HTTPStatusCode, error in
                
                if let data = data, jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
//                    let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String

                    var str = jsonString.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: jsonString.rangeOfString(jsonString))
                    str = str.stringByDecodingHTMLEntities


                    let newStrippedData = str.dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        let JSON = try NSJSONSerialization.JSONObjectWithData(newStrippedData!, options: NSJSONReadingOptions(rawValue: 0))

                        if let JSON = JSON as? NSDictionary {
                            let imageURLString = JSON["media_details"]?["sizes"]??["medium"]??["source_url"]
        //                        let imageURLString = JSON["media_details"]?["sizes"]??["large"]??["source_url"]
                            print("imageURLString: \(imageURLString)")
                            post.image = imageURLString as? String

                            completionHandler()
                        }else {
                            print("JSON PARSE FAIL: \(JSON)")
                            completionHandler()
                        }
                    }catch {
                        
                        // NOTE: Required for WordPress image retrieval issue - reattempts request.
                        self.retrieveImageSourceURLForPost(post, completionHandler: completionHandler)
                        
//                        completionHandler()
                    }
                    
                }else {
                    completionHandler()
                }

            })

        }else {
            // TODO: Add handler
            
            print("retrieving image for url failed: \(post.mediaURLString)")
            completionHandler()
        }
    }
}