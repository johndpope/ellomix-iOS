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

class LinkedAccountViewController: UIViewController {
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        spotifyButton.layer.cornerRadius = spotifyButton.frame.height / 2
        facebookButton.layer.cornerRadius = facebookButton.frame.height / 2
    }
    
    // LOGIN WITH FACEBOOK AND ATTACHED LINKED ACCOUNT
    
    // SPOTIFY AUTHENTICATION
    @IBAction func spotifyButtonPressed(_ sender: Any) {
        let webURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()!
        
        // Before presenting the view controllers we are going to start watching for the notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receievedUrlFromSpotify(_:)),
                                               name: NSNotification.Name.Spotify.authURLOpened,
                                               object: nil)
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(webURL)
        }
    }
    
    
    func receievedUrlFromSpotify(_ notification: Notification) {
        guard let url = notification.object as? URL else { return }
                
        // Remove the observer from the Notification Center
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.Spotify.authURLOpened,
                                                  object: nil)
        
        SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url) { (error, session) in
            if let error = error {
                // Pass our error onto another method which will determine how to show it
                self.displayErrorMessage(error: error)
                return
            }
            
            if let session = session {
                // The streaming login is asyncronious and will alert us if the user
                // was logged in through a delegate, so we need to implement those methods
                SPTAudioStreamingController.sharedInstance().delegate = self
                SPTAudioStreamingController.sharedInstance().login(withAccessToken: session.accessToken)
            }
        }
    }
    
    func displayErrorMessage(error: Error) {
        // When changing the UI, all actions must be done on the main thread,
        // since this can be called from a notification which doesn't run on
        // the main thread, we must add this code to the main thread's queue
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error",
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func successfulLogin() {
        // When changing the UI, all actions must be done on the main thread,
        // since this can be called from a notification which doesn't run on
        // the main thread, we must add this code to the main thread's queue
        
        DispatchQueue.main.async {
            // Present next view controller or use performSegue(withIdentifier:, sender:)
            self.present(LoginViewController(), animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LinkedAccountViewController: SPTAudioStreamingDelegate {
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        self.successfulLogin()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        displayErrorMessage(error: error)
    }
}
