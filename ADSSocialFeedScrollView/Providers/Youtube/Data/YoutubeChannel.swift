//
//  YoutubeChannel.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 13/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit

let YOUTUBE_DATA_API_BASE_URL_STRING = "https://www.googleapis.com/youtube/v3"

class YoutubeChannel: PostCollectionProtocol {
    
    private(set) var id             : String
    private(set) var name           : String!
    private(set) var profileImage   : String!
    private(set) var description    : String!
    
    private(set) var playlists      : Array<YoutubePlaylist>!
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(id: String) {
        self.id = id
    }
    
    //*********************************************************************************************************
    // MARK: - Data retrievers
    //*********************************************************************************************************
    
    func fetchChannelInfoInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        var urlString = targetURLStringWithBaseURLString(YOUTUBE_DATA_API_BASE_URL_STRING, RESTEndpoint: "channels", apiKey: ADSSocialFeedYoutubeAccountProvider.authKey)
        urlString = addParamToURLString(urlString, paramKey: "part", paramValue: "contentDetails,snippet")
        urlString = addParamToURLString(urlString, paramKey: "id", paramValue: self.id)
        
        performGetRequest(urlWithUrlString(urlString), completion: {
            data, statusCode, error in
            
            if let data = data {
                if let resultsDict = JSONObjectWithData(data) {
                    
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    let items: AnyObject! = resultsDict["items"] as AnyObject!
                    let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>
                    
                    // Get the snippet dictionary that contains the desired data.
                    let snippetDict = firstItemDict["snippet"] as! Dictionary<NSObject, AnyObject>
                    
                    // Create a new dictionary to store only the values we care about.
                    var desiredValuesDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
                    desiredValuesDict["title"] = snippetDict["title"]
                    desiredValuesDict["description"] = snippetDict["description"]
                    desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                    
                    self.name = snippetDict["title"] as? String
                    self.description = snippetDict["description"] as? String
                    self.profileImage = ((snippetDict["thumbnails"] as? Dictionary<NSObject, AnyObject>)?["default"] as? Dictionary<NSObject, AnyObject>)?["url"] as? String
                }
                
            }else {
                NSLog("[ADSSocialFeedScrollView][Youtube] An error occurred while fetching channel info: \(error?.description)")
            }
            
//            self.fetchPublicChannelPlaylistsInBackgroundWithCompletionHandler(block)
            
            var tempPlaylists = self.playlists
            self.playlists = [YoutubePlaylist]()
            
            self.fetchPublicChannelPlaylistsInBackgroundWithCompletionHandler({
            
////                let playlistId = "PLHFlHpPjgk71-8cHGcN7GpjIimFcVIC4X"
////                let playlistId = "PL14KBd2ilsXIVuY47_7QBqCMK5DUSz2hG"
//                
//                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                    
//                    var completionCount = 0
//                    
//                    for playlistId in ADSSocialFeed.sYoutubePlaylistIds {
//                        // TODO: Examine usefulness.
//                        if self.playlists.filter({$0.id == playlistId}).count == 1 {
//                            completionCount += 1
//                            continue
//                        }
//                        
//                        self.fetchPlaylistsInBackgroundWithOptions(false, withPlaylistId: playlistId, block: {
//                            completionCount += 1
//                        })
//                    }
//                    
//                    repeat {} while completionCount < ADSSocialFeed.sYoutubePlaylistIds.count
                
                    if self.playlists.count == 0 {
                        self.playlists = tempPlaylists
                    }
                
                block?()
                
            })
        })
    }
    
    private func fetchPublicChannelPlaylistsInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        self.fetchPlaylistsInBackgroundWithOptions(true, withPlaylistId: nil, block: block)
    }
    
    private func fetchPlaylistsInBackgroundWithOptions(fetchOnlyChannelPlaylists: Bool, withPlaylistId playlistId: String?, block: (() -> Void)?) {
        var urlString = targetURLStringWithBaseURLString(YOUTUBE_DATA_API_BASE_URL_STRING, RESTEndpoint: "playlists", apiKey: ADSSocialFeedYoutubeAccountProvider.authKey)
        urlString = addParamToURLString(urlString, paramKey: "part", paramValue: "contentDetails,snippet")
        if fetchOnlyChannelPlaylists {
            urlString = addParamToURLString(urlString, paramKey: "channelId", paramValue: self.id)
        }
        if let playlistId = playlistId {
            urlString = addParamToURLString(urlString, paramKey: "id", paramValue: playlistId)
        }
        
        performGetRequest(urlWithUrlString(urlString), completion: {
            data, statusCode, error in
            
            if let data = data {
                if let resultsDict = JSONObjectWithData(data) {
                    
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    let items: [[String: AnyObject]] = resultsDict["items"] as! [[String: AnyObject]]
                    
//                    self.playlists = [YoutubePlaylist]()
                    
                    var loadCount = 0
                    
                    for playlistDataDict in items {
                        let snippetDict = playlistDataDict["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Create a new dictionary to store only the values we care about.
                        var desiredValuesDict: Dictionary<String, String> = Dictionary<String, String>()
                        desiredValuesDict["title"] = snippetDict["title"] as? String
                        desiredValuesDict["description"] = snippetDict["description"] as? String
                        desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"] as? String
                        desiredValuesDict["publishedAt"] = snippetDict["publishedAt"] as? String
                        
                        // Save the playlist ID.
                        desiredValuesDict["playlistId"] = playlistDataDict["id"] as? String
                        
                        //Create a new YoutubePlaylist instance
                        let youtubePlaylist = YoutubePlaylist(id: desiredValuesDict["playlistId"]!)
                        youtubePlaylist.title = desiredValuesDict["title"]
                        youtubePlaylist.description = desiredValuesDict["description"]
                        youtubePlaylist.thumbnailImageURL = desiredValuesDict["thumbnail"]
                        youtubePlaylist.publishedAt = desiredValuesDict["publishedAt"]
                        
                        //TODO: Verify!!!
                        youtubePlaylist.fetchPlaylistItemsInBackgroundWithCompletionHandler({
                            loadCount += 1
                            
                            if loadCount >= items.count {
                                block?()
                            }
                        })
                        
                        self.playlists.append(youtubePlaylist)
                    }
                }else {
                    block?()
                }
                
                
            }else {
                NSLog("[ADSSocialFeedScrollView][Youtube] An error occurred while fetching channel info: \(error?.description)")
                
                block?()
            }
        })
    }
    
    internal class func fetchStandalonePlaylistsInBackground(block: (() -> Void)?) {
        
        var tempPlaylists = ADSSocialFeed.sYoutubePlaylists
        ADSSocialFeed.sYoutubePlaylists = [YoutubePlaylist]()
        
        var completionCount = 0
        
        var completionBlock = {
            
            completionCount += 1
            
            if completionCount < ADSSocialFeed.sYoutubePlaylistIds.count {
                return
            }
            
            if ADSSocialFeed.sYoutubePlaylists.count == 0 {
                ADSSocialFeed.sYoutubePlaylists = tempPlaylists
            }
            
            block?()
        }
        
        for playlistId in ADSSocialFeed.sYoutubePlaylistIds {
            // TODO: Examine usefulness.
            if ADSSocialFeed.sYoutubePlaylists.filter({$0.id == playlistId}).count == 1 {
                completionBlock()
                continue
            }
            
            self.fetchStandalonePlaylistInBackgroundWithPlaylistId(playlistId, block: {
                completionBlock()
            })
        }
    }
    
    private class func fetchStandalonePlaylistInBackgroundWithPlaylistId(playlistId: String?, block: (() -> Void)?) {
        
        var urlString = targetURLStringWithBaseURLString(YOUTUBE_DATA_API_BASE_URL_STRING, RESTEndpoint: "playlists", apiKey: ADSSocialFeedYoutubeAccountProvider.authKey)
        urlString = addParamToURLString(urlString, paramKey: "part", paramValue: "contentDetails,snippet")
        if let playlistId = playlistId {
            urlString = addParamToURLString(urlString, paramKey: "id", paramValue: playlistId)
        }
        
        performGetRequest(urlWithUrlString(urlString), completion: {
            data, statusCode, error in
            
            if let data = data {
                if let resultsDict = JSONObjectWithData(data) {
                    
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    let items: [[String: AnyObject]] = resultsDict["items"] as! [[String: AnyObject]]
                    
                    //                    self.playlists = [YoutubePlaylist]()
                    
                    var loadCount = 0
                    
                    for playlistDataDict in items {
                        let snippetDict = playlistDataDict["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Create a new dictionary to store only the values we care about.
                        var desiredValuesDict: Dictionary<String, String> = Dictionary<String, String>()
                        desiredValuesDict["title"] = snippetDict["title"] as? String
                        desiredValuesDict["description"] = snippetDict["description"] as? String
                        desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"] as? String
                        desiredValuesDict["publishedAt"] = snippetDict["publishedAt"] as? String
                        
                        // Save the playlist ID.
                        desiredValuesDict["playlistId"] = playlistDataDict["id"] as? String
                        
                        //Create a new YoutubePlaylist instance
                        let youtubePlaylist = YoutubePlaylist(id: desiredValuesDict["playlistId"]!)
                        youtubePlaylist.title = desiredValuesDict["title"]
                        youtubePlaylist.description = desiredValuesDict["description"]
                        youtubePlaylist.thumbnailImageURL = desiredValuesDict["thumbnail"]
                        youtubePlaylist.publishedAt = desiredValuesDict["publishedAt"]
                        
                        //TODO: Verify!!!
                        youtubePlaylist.fetchPlaylistItemsInBackgroundWithCompletionHandler({
                            loadCount += 1
                            
                            if !(loadCount < items.count) {
                                block?()
                            }
                        })
                        
                        ADSSocialFeed.sYoutubePlaylists.append(youtubePlaylist)
                    }
                }
                
                
            }else {
                NSLog("[ADSSocialFeedScrollView][Youtube] An error occurred while fetching channel info: \(error?.description)")
                
                block?()
            }
        })
    }
    
    //*********************************************************************************************************
    // MARK: - PostCollectionProtocol
    //*********************************************************************************************************
    
    var postItems: [PostProtocol]? {
        return self.playlists.reduce([PostProtocol](), combine: { (acc, playlist) in
            return (acc ?? []) + (playlist.postItems ?? [])
        })
    }
    
}
