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
    
    func search(query: String) {
        let auth: SPTAuth = SPTAuth.defaultInstance()
        let token = auth.session.accessToken
        
        if (token != nil) {
            SPTSearch.perform(withQuery: query, queryType: .queryTypeTrack, accessToken: token) { (error, result) in
                print("--------------REQUESTING FROM SPOTIFY---------------")
                if let songs = result as? SPTListPage {
                    for song in songs.items {
                        let song = song as! SPTPartialTrack
                        print(song.name)
                    }
                }
            }
        } else {
            print("Spotify not authenticated.")
        }
    }
}
