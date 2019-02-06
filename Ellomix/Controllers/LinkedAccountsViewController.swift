//
//  LinkedAccountsViewController.swift
//  Ellomix
//
//  Created by akshay.vyas on 7/19/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation
import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import SafariServices
import AVFoundation

// This is for linking accounts if a person has already logged in with one account.
// FACEBOOK and SPOTIFY

class LinkedAccountViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    @IBAction func spotifyButtonPressed(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(loginUrl!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        spotifyButton.layer.cornerRadius = spotifyButton.frame.height / 2
        facebookButton.layer.cornerRadius = facebookButton.frame.height / 2
        
        self.setup()
        NotificationCenter.default.addObserver(self, selector: #selector(LinkedAccountViewController.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessful"), object: nil)
    }

// LOGIN WITH FACEBOOK AND ATTACHED LINKED ACCOUNT
    
// SPOTIFY AUTHENTICATION
    @objc func updateAfterFirstLogin () {
        spotifyButton.isHidden = true
        let userDefaults = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        }
    }
    
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            do {
                try self.player?.start(withClientId: auth.clientID)
            } catch {
                print("Failed to start with clientId")
            }
            self.player!.login(withAccessToken: authSession.accessToken)
            print("Player has been initialized")
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup () {
        // insert redirect your url and client ID below
        let redirectURL = "ellomix://return-after-login" // put your redirect URL here
        let clientID = "a3d3b4620139433b96ff80890e3a584b" // put your client ID here
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = clientID
        // put your scopes here
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserLibraryReadScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
    }
}


