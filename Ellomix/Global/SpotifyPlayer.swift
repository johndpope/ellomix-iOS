//
//  SpotifyPlayer.swift
//  Ellomix
//
//  Created by Kevin Avila on 3/4/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

class SpotifyPlayer {
    func play(id: String) {
        SPTAudioStreamingController.sharedInstance()?.playSpotifyURI("spotify:track:" + id, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error == nil) {
                print("Playing Spotify track.")
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
    func pause() {
        SPTAudioStreamingController.sharedInstance()?.setIsPlaying(false, callback: nil)
    }
    
    func playPause(button: UIButton) {
        if isPlaying() {
            button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            SPTAudioStreamingController.sharedInstance()?.setIsPlaying(false, callback: nil)
        } else {
            button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            SPTAudioStreamingController.sharedInstance()?.setIsPlaying(true, callback: nil)
        }
    }
    
    func setButton(button: UIButton) {
        if isPlaying() {
            button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    func isPlaying() -> Bool {
        if (SPTAudioStreamingController.sharedInstance().playbackState != nil) {
            return SPTAudioStreamingController.sharedInstance().playbackState.isPlaying
        }
        
        return false
    }
}
