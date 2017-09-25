//
//  YoutubePlaylist.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 17/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation

class YoutubePlaylist: PostCollectionProtocol {
    
    private(set) var id                 : String
    internal(set) var title              : String!
    internal(set) var description        : String!
    internal(set) var thumbnailImageURL  : String!
    internal(set) var publishedAt        : String!
    private(set) var publishedAt_DATE   : NSDate!
    
    private(set) var videos             : Array<YoutubeVideo>!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(id: String) {
        self.id = id
    }
    
    //*********************************************************************************************************
    // MARK: - Data retrievers
    //*********************************************************************************************************
    
    internal func fetchPlaylistItemsInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        // Form the request URL string.
        var urlString = targetURLStringWithBaseURLString(YOUTUBE_DATA_API_BASE_URL_STRING, RESTEndpoint: "playlistItems", apiKey: ADSSocialFeedYoutubeAccountProvider.authKey)
        urlString = addParamToURLString(urlString, paramKey: "part", paramValue: "snippet")
        urlString = addParamToURLString(urlString, paramKey: "playlistId", paramValue: self.id)
        urlString = addParamToURLString(urlString, paramKey: "maxResults", paramValue: "50")
        
        // Create a NSURL object based on the above string.
        let targetURL = NSURL(string: urlString)
        
        // Fetch the playlist from Google.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // Convert the JSON data into a dictionary.
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all playlist items ("items" array).
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    self.videos = Array<YoutubeVideo>()
                    
                    // Use a loop to go through all video items.
//                    for var i=0; i<items.count; ++i {         // TODO: Investigate why ++i was used here.
                    for i in 0 ..< items.count {
                        let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        var desiredPlaylistItemDataDict = Dictionary<NSObject, AnyObject>()
                        
                        desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                        
                        // TODO: Add default (private video) thumbnail image
                        
                        desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                        
                        let videoId = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"] as! String
                        let title = playlistSnippetDict["title"] as! String
                        let description = playlistSnippetDict["description"] as! String
                        
                        let thumbnailImageURL = "http://img.youtube.com/vi/\(videoId)/mqdefault.jpg"
                        
                        let publishedAt = playlistSnippetDict["publishedAt"] as! String
                        
                        let video: YoutubeVideo = YoutubeVideo(playlist: self, videoId: videoId, title: title, description: description, thumbnailImageURL: thumbnailImageURL, publishedAt: publishedAt)
                        
                        self.videos.append(video)
                    }
                    
                    self.videos = self.videos.sort({ $0.publishedAt_DATE.compare($1.publishedAt_DATE) == NSComparisonResult.OrderedDescending })
                } catch let error as NSError {
                    NSLog("[ADSSocialFeedScrollView][Youtube] An error occurred while processing playlist item: \(error.description)")
                }
            }else {
                NSLog("[ADSSocialFeedScrollView][Youtube] An error occurred while fetching playlist item: \(error?.description)")
            }
            
//            dispatch_async(dispatch_get_main_queue(), {
                block?()
//            })
        })
    }
    
    //*********************************************************************************************************
    // MARK: - PostCollectionProtocol
    //*********************************************************************************************************
    
    var postItems: [PostProtocol]? {
        // See: https://stackoverflow.com/a/30101004/699963
        return self.videos.map({ $0 as PostProtocol })
    }
    
}
