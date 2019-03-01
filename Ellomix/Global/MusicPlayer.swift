//
//  MusicPlayer.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayer: NSObject {
    
    var player: AVPlayer?
    var baseDelegate: ContainerViewController!
    
    override init() {
        super.init()
        commandCenterHandlers()
    }
    
    func play(url: URL) {
        player = AVPlayer()
        initPlayer()
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        NotificationCenter.default.addObserver(baseDelegate, selector: #selector(ContainerViewController.musicPlayerFinishedPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player?.replaceCurrentItem(with: playerItem)
        player?.rate = 1.0;
        player?.play()
    }
    
    func playSpotify(id: String) {
        SPTAudioStreamingController.sharedInstance()?.playSpotifyURI("spotify:track:" + id, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error == nil) {
                print("Playing Spotify track.")
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
    func playPause(button: UIButton) {
        if isPlaying() {
            button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player?.pause()
        } else {
            button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            player?.play()
        }
        if isPlayingSpotify() {
            button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            SPTAudioStreamingController.sharedInstance()?.setIsPlaying(false, callback: nil)
            print("Spotify pause.")
        } else {
            button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            SPTAudioStreamingController.sharedInstance()?.setIsPlaying(true, callback: nil)
            print("Spotify play.")
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
        return player?.rate != 0 && player?.error == nil
    }
    
    func isPlayingSpotify() -> Bool {
        return (SPTAudioStreamingController.sharedInstance()?.playbackState.isPlaying)!
    }
    
    func updateNowPlayingInfoCenter(track: Any?) {
        if (track is SoundcloudTrack) {
            let track = track as! SoundcloudTrack
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: track.title ?? "",
                //MPMediaItemPropertyAlbumTitle: track ?? "",
                MPMediaItemPropertyArtist: track.artist ?? "",
                //MPMediaItemPropertyPlaybackDuration: audioPlayer.duration,
                //MPNowPlayingInfoPropertyElapsedPlaybackTime: audioPlayer.progress
            ]
            if let artwork = track.thumbnailImage {
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: artwork)
            }
        }
    }
    
    private func initPlayer() {
        if #available(iOS 10.0, *) {
            player?.automaticallyWaitsToMinimizeStalling = false
        }
        self.player?.allowsExternalPlayback = true
        self.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
    
    private func commandCenterHandlers() {
        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
            self.player?.play()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
            self.player?.pause()
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {event in
            //self.next()
            return .success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {event in
            //self.prev()
            return .success
        }
    }
}
