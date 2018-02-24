//
//  MusicPlayer.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class MusicPlayer {
    
    var player: AVPlayer?
    
    func play(url: URL) {
        player = AVPlayer()
        initPlayer()
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player?.replaceCurrentItem(with: playerItem)
        player?.rate = 1.0;
        player?.play()
        
//        if isPlaying() {
//            player?.pause()
//        } else {
//            player?.play()
//        }
    }
    
    private func isPlaying() -> Bool {
        return player?.rate != 0 && player?.error == nil
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
}
