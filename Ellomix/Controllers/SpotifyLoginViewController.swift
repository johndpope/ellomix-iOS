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

class SpotifyLoginViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    
    // Initialzed in either updateAfterFirstLogin: (if first time login) or in viewDidLoad (when there is a check for a session object in User Defaults
    var player:SPTAudioStreamingController?
    var loginUrl:URL?
    
    //TODO: Move spotify login to before search and see how to refresh access token from within search screen and player VC
    
    @IBOutlet weak var loginButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //loginButton.isHidden = false
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(SpotifyLoginViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    
    //TODO: Add callback when the login is successful
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup () {
        // insert redirect your url and client ID below
        let redirectURL = "Ellomix://returnAfterLogin" // put your redirect URL here
        let clientID = "a3d3b4620139433b96ff80890e3a584b" // put your client ID here
        auth = SPTAuth.defaultInstance()
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = clientID
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
        
        
        
        //
        if UIApplication.shared.openURL(loginUrl!) {
            
            if auth.canHandle(auth.redirectURL) {
                
                // handle callback in closure
                auth.handleAuthCallback(withTriggeredAuthURL: auth.redirectURL, callback: { (error, session) in
                    
                    print("setup auth handle successful")
                    // handle error
                    if error != nil {
                        print("error!")
                    }
                    print("callback called")
                    
                })
                
            }
        }
        
    }
    
    // Do not need player in this screen, but will need this code
    func initializaPlayer(authSession:SPTSession) {
        
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func updateAfterFirstLogin () {
        
        print("First login handle")
        
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            initializaPlayer(authSession: session)
            //            self.loginButton.isHidden = true
            // self.loadingLabel.isHidden = false
            
        }
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("audio streaming logged in")
        performSegue(withIdentifier: "spotifyLoginDone", sender: nil)
        //        self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
        //            if (error != nil) {
        //                print("playing!")
        //            }
        //
        //        })
        
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {

        if UIApplication.shared.openURL(loginUrl!) {

            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling

                // handle callback in closure
                auth.handleAuthCallback(withTriggeredAuthURL: auth.redirectURL, callback: { (error, session) in

                    print("Login button auth handle successful")
                    // handle error
                    if error != nil {
                        print("error!")
                    }
                    print("callback called")

                })

            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
