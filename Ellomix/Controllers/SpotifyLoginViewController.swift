//
//  SpotifyLoginViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/26/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class SpotifyLoginViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    fileprivate let SpotifyClientID = "a3d3b4620139433b96ff80890e3a584b"
    fileprivate let SpotifyRedirectURI = URL(string: "ellomix://returnAfterLogin")!
    
    //spotify configuration
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        
        // Set these url's to your backend ( for firebase if needed --> idk yet
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
}
