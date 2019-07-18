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
    static let tokenRefreshURL = URL(string: "https://us-central1-ellomix-dev.cloudfunctions.net/spotifyAuth/refresh")
    static let tokenSwapURL = URL(string: "https://us-central1-ellomix-dev.cloudfunctions.net/spotifyAuth/swap")
}

extension Notification.Name {
    struct Spotify {
        static let authURLOpened = Notification.Name("authURLOpened")
    }
}

class SpotifyService {
    let auth: SPTAuth = SPTAuth.defaultInstance()
    var accessToken: String! // Look over how authentication is being handled. This may not be needed. 
    
    func search(query: String, completed: @escaping ([SpotifyTrack]) -> ()) {
        if auth.session != nil {
            if auth.session.isValid() == false {
                refreshToken()
            }
            let token = auth.session.accessToken
            var songs = [SpotifyTrack]()
            
            SPTSearch.perform(withQuery: query, queryType: .queryTypeTrack, accessToken: token) { (error, result) in
                print("--------------REQUESTING FROM SPOTIFY---------------")
                
                if let listPage = result as? SPTListPage,
                    let items = listPage.items as? [SPTPartialTrack] {
                    for item in items {
                        let spTrack = SpotifyTrack()
                        
                        spTrack.title = item.name

                        let artist = item.artists.first as? SPTPartialArtist
                        spTrack.artist = artist?.name

                        spTrack.url = item.previewURL
                        spTrack.id = item.identifier
                        spTrack.source = "spotify"
                        
                        let thumbnailURL = item.album.largestCover.imageURL

                        if (thumbnailURL != nil) {
                            spTrack.thumbnailURL = thumbnailURL?.absoluteString
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: thumbnailURL!) {
                                    DispatchQueue.main.async {
                                        spTrack.thumbnailImage = UIImage(data: data)
                                    }
                                }
                            }
                        }
                        
                        songs.append(spTrack)
                    }
                    completed(songs)
                }
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        if auth.session == nil || auth.session.accessToken == nil {
            print("User is not logged into Spotify.")
            EllomixAlertController.showAlert(viewController: topViewController()!,
                                             title: "Spotify Login Required",
                                             message: "You are trying to play a Spotify track. Please login with Spotify to listen.")
            return false
        }
        if auth.session.isValid() == false {
            refreshToken()
        }
        initializePlayer()
        return true
    }
    
    func initializePlayer() {
        if SPTAudioStreamingController.sharedInstance()?.loggedIn != true {
            SPTAudioStreamingController.sharedInstance()?.login(withAccessToken: auth.session.accessToken)
        }
    }
    
    func refreshToken() {
        SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session) { error, session in
            SPTAuth.defaultInstance().session = session
            if error != nil {
                print("Refreshing token failed.")
                print("*** Error renewing session: \(String(describing: error))")
                return
            }
        }
    }
    
    func topViewController() -> UIViewController? {
        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        while topViewController.presentedViewController != nil {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
}
