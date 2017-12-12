//
//  MusicPlayer.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation
import AVFoundation

class MusicPlayer {
    
    var audioPlayer = AVPlayer()
    
    func play(url: URL) {
        
        audioPlayer = AVPlayer(url: url)
        audioPlayer.rate = 1.0;
        
        if isPlaying() {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
    
    private func isPlaying() -> Bool {
        return audioPlayer.rate != 0 && audioPlayer.error == nil
    }
}
