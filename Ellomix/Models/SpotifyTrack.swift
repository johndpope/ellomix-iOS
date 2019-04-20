//
//  SpotifyTrack.swift
//  Ellomix
//
//  Created by Akshay Vyas on 3/18/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

internal class SpotifyTrack: BaseTrack {

    var url: URL?
    
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
