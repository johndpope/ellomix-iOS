//
//  SoundcloudService.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/19/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation
import Soundcloud

class SoundcloudService {
    
    func search(query: String, completed: @escaping ([SoundcloudTrack]) -> ()) {
        var songs = [SoundcloudTrack]()
        Track.search(queries: [.queryString(query)]) { response in
            print("--------------REQUESTING FROM SOUNDCLOUD---------------")
            //print("Soundcloud response: \(response.response.result)")
            if let tracks = response.response.result {
                for track in tracks {
                    let scTrack = SoundcloudTrack()
                    
                    scTrack.title = track.title
                    scTrack.artist = track.createdBy.username
                    scTrack.url = track.streamURL
                    scTrack.id = String(track.identifier)
                    if (track.artworkImageURL.highURL != nil) {
                        scTrack.thumbnailURL = track.artworkImageURL.highURL
                    } else {
                        scTrack.thumbnailImage = #imageLiteral(resourceName: "ellomix_logo_bw")
                    }
                    
                    if (scTrack.thumbnailURL != nil) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: scTrack.thumbnailURL!) {
                                DispatchQueue.main.async {
                                    scTrack.thumbnailImage = UIImage(data: data)
                                    completed(songs)
                                }
                            }
                        }
                    }
                    
                    songs.append(scTrack)
                }
                
                completed(songs)
            }
        }
    }
    
}
