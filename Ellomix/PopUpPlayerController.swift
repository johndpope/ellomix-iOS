//
//  PopUpPlayerController.swift
//  Ellomix
//
//  Created by Kevin Avila on 1/27/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class PopUpPlayerController: UIViewController {
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var artistField: UILabel!
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var playPauseButton: UIImageView!
    var currentTrack: Any?
    
    override func viewDidLoad() {
        loadTrackInfo()
    }
    
    func loadTrackInfo() {
        switch currentTrack {
        case is SoundcloudTrack:
            print("Soundcloud song loaded in popup player.")
        case is YouTubeVideo:
            let track = currentTrack as! YouTubeVideo
            titleField.text = track.videoTitle
            artistField.text = track.videoChannel
        default:
            print("Unable to load track info.")
        }
    }
}
