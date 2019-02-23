//
//  SpotifyService.swift
//  Ellomix
//
//  Created by Abelardo Torres on 9/19/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation
import Alamofire

struct Constants {
    static let clientID = "a3d3b4620139433b96ff80890e3a584b"
    static let redirectURI = URL(string: "ellomix://return-after-login")!
    static let sessionKey = "spotifySessionKey"
}

extension Notification.Name {
    struct Spotify {
        static let authURLOpened = Notification.Name("authURLOpened")
    }
}

class SpotifyService {
    var accessToken: String! // Look over how authentication is being handled. This may not be needed. 
    
    func search(query: String, completed: @escaping ([SpotifyTrack]) -> ()) {
        let auth: SPTAuth = SPTAuth.defaultInstance()
        
        if auth.session != nil {
            let token = auth.session.accessToken
            
            var songs = [SpotifyTrack]()
            
            SPTSearch.perform(withQuery: query, queryType: .queryTypeTrack, accessToken: token) { (error, result) in
                print("--------------REQUESTING FROM SPOTIFY---------------")
                
                if let listPage = result as? SPTListPage,
                    let items = listPage.items as? [SPTPartialTrack],
                    let artist = items.first?.artists.first as? SPTPartialArtist {
                    for item in items {
                        let spTrack = SpotifyTrack()
                        
                        spTrack.title = item.name
                        spTrack.artist = artist.name
                        spTrack.url = item.previewURL
                        spTrack.thumbnailURL = item.album.largestCover.imageURL
                        spTrack.id = item.identifier
                        
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: spTrack.thumbnailURL!) {
                                DispatchQueue.main.async {
                                    spTrack.thumbnailImage = UIImage(data: data)
                                    completed(songs)
                                }
                            }
                        }
                        songs.append(spTrack)
                    }
                    completed(songs)
                }
            }
        } else {
            print("User is not signed into Spotify.")
        }
    }
}
