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
                    scTrack.source = "soundcloud"

                    DispatchQueue.global().async {
                        if let thumbnailURL = track.artworkImageURL.highURL, let data = try? Data(contentsOf: thumbnailURL) {
                            DispatchQueue.main.async {
                                scTrack.thumbnailURL = thumbnailURL.absoluteString
                                scTrack.thumbnailImage = UIImage(data: data)
                                completed(songs)
                            }
                        } else {
                            scTrack.thumbnailImage = #imageLiteral(resourceName: "ellomix_logo_bw")
                        }
                    }

                    songs.append(scTrack)
                }
                
                completed(songs)
            }
        }
    }
    
    func getTrackById(id: Int, completed: @escaping (Track) -> ()) {
        Track.track(identifier: id, completion: {(result: SimpleAPIResponse<Track>) -> Void in
            if let track = result.response.result {
                completed(track)
            }
        })
    }
    
}
