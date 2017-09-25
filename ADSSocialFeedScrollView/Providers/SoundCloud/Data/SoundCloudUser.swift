//
//  SoundCloudUser.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 26/03/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import Foundation
import SwiftyJSON

class SoundCloudUser {
    
    private(set) var id             : String
    private(set) var website_title  : String!
    private(set) var avatar_url     : String!
    
    private(set) var tracks         : Array<SoundCloudTrack> = [SoundCloudTrack]()
    
    //*********************************************************************************************************
    // MARK: - Constructors
    //*********************************************************************************************************
    
    init(id: String) {
        self.id = id
    }
    
    //*********************************************************************************************************
    // MARK: - Data retrievers
    //*********************************************************************************************************
    
    func fetchUserInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.fetchUserInfoInBackgroundForUserId(self.id, clientId: ADSSocialFeedSoundCloudAccountProvider.clientId, completionHandler: {
                self.fetchTracksInBackgroundWithCompletionHandler(block)
            })
        })
    }
    
    private func fetchTracksInBackgroundWithCompletionHandler(block: (() -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.fetchTracksInBackgroundForUserId(self.id, clientId: ADSSocialFeedSoundCloudAccountProvider.clientId, completionHandler: {
                block?()
            })
        })
    }
    
    private func fetchUserInfoInBackgroundForUserId(userId: String, clientId: String, completionHandler block: (() -> Void)?) {
        let url: NSURL! = NSURL(string: "https://api.soundcloud.com/users/\(userId)?client_id=\(clientId)")
        
        performGetRequest(url, completion: {
            data, statusCode, error in
            
            if let data = data {
                
                if let userDict = JSON.init(data: data).dictionary {
                    
                    self.website_title  = userDict["website_title"]?.string
                    self.avatar_url     = userDict["avatar_url"]?.string
                }
            }else {
                NSLog("[ADSSocialFeedScrollView][SoundCloud] An error occurred while fetching user info: \(error?.description)");
            }
            
            block?()
        })
    }
    
    private func fetchTracksInBackgroundForUserId(userId: String, clientId: String, completionHandler block: (() -> Void)?) {
        let url: NSURL! = NSURL(string: "https://api.soundcloud.com/users/\(userId)/tracks?client_id=\(clientId)")
        
        performGetRequest(url, completion: {
            data, statusCode, error in
            
            if let data = data {
                
                if let tracksArray = JSON.init(data: data).array {
                    
                    self.tracks.removeAll()
                    
                    for trackDict in tracksArray {
                        
                        let track: SoundCloudTrack = SoundCloudTrack(dataPayload: trackDict)
                        
                        if let stream_url = trackDict["stream_url"].string {
                            let stream_url = "\(stream_url)?client_id=\(clientId)"
                            
                            track.stream_url = stream_url
                            self.tracks.append(track)
                        }
                        
                    }
                }
            }else {
                NSLog("[ADSSocialFeedScrollView][SoundCloud] An error occurred while fetching tracks: \(error?.description)");
            }
            
            block?()
        })
    }
    
}
