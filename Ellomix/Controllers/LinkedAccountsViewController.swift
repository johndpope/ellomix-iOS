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

class LinkedAccountViewController: UIViewController, SPTAudioStreamingDelegate {
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    private var spService: SpotifyService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        spService = SpotifyService()
        
        spotifyButton.layer.cornerRadius = spotifyButton.frame.height / 2
        facebookButton.layer.cornerRadius = facebookButton.frame.height / 2
        
        if SPTAuth.defaultInstance().session != nil || SPTAuth.defaultInstance().session.accessToken != nil || SPTAuth.defaultInstance().session.isValid() != false {
            spotifyButton.backgroundColor = UIColor.gray
            spotifyButton.setTitle("Logged into Spotify", for: .disabled)
            spotifyButton.isEnabled = false
        }
    }
    // LOGIN WITH FACEBOOK AND ATTACHED LINKED ACCOUNT
    
    // SPOTIFY AUTHENTICATION
    @IBAction func spotifyButtonPressed(_ sender: Any) {
        let webURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(webURL)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
