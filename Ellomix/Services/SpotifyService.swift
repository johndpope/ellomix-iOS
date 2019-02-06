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
    
}
