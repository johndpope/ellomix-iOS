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
    var currentTrack: Any?
    var playbar: PlayBarController?
    
    override func viewDidLoad() {

    }

    override func viewWillAppear(_ animated: Bool) {
        loadTrackInfo()
        if (Global.sharedGlobal.youtubePlayer?.playerState == YouTubePlayerState.Playing) {
            self.view.addSubview(Global.sharedGlobal.youtubePlayer!)
            Global.sharedGlobal.youtubePlayer?.frame = CGRect(x: 0, y: 125, width: self.view.frame.width, height: 272)
            Global.sharedGlobal.youtubePlayer?.play()
        }
    }
    
    func loadTrackInfo() {
        switch currentTrack {
        case is SoundcloudTrack:
            artworkImage.isHidden = false
            let track = currentTrack as! SoundcloudTrack
            artworkImage.image = track.thumbnailImage
            titleField.text = track.title
            artistField.text = track.artist
        case is YouTubeVideo:
            artworkImage.isHidden = true
            let track = currentTrack as! YouTubeVideo
            titleField.text = track.videoTitle
            artistField.text = track.videoChannel
        default:
            print("Unable to load track info.")
        }
    }
    
    @IBAction func dismissPlayer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
