//
//  PlayBarController.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class PlayBarController: UIViewController {
    
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playbarArtwork: UIImageView!
    @IBOutlet weak var playbarTitle: UILabel!
    @IBOutlet weak var playbarArtist: UILabel!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    
    override func viewDidLoad() {
        youtubePlayer.isHidden = true
        youtubePlayer.playerVars = ["playsinline": 1 as AnyObject, "showinfo": 0 as AnyObject, "rel": 0 as AnyObject, "modestbranding": 1 as AnyObject, "controls": 1 as AnyObject]
    }
}
