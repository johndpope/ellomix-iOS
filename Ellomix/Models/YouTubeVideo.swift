//
//  YouTubeVideo.swift
//  Ellomix
//
//  Created by Kevin Avila on 5/6/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

internal class YouTubeVideo: BaseTrack {
   
    var videoDescription: String?

    convenience init(baseTrack: BaseTrack) {
        self.init()
        self.id = baseTrack.id
        self.title = baseTrack.title
        self.artist = baseTrack.artist
        self.thumbnailURL = baseTrack.thumbnailURL
        self.thumbnailImage = baseTrack.thumbnailImage
        self.source = baseTrack.source
        self.order = baseTrack.order
        self.sid = baseTrack.sid
    }
}
