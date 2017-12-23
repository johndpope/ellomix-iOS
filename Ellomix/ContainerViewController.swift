//
//  ContainerViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    
    @IBOutlet weak var playBarView: UIView!
    
    private var musicPlayer: MusicPlayer!
    var playBarController: PlayBarController!
    
    override func viewDidLoad() {
        playBarView.isHidden = true
        playBarController.placeholderView.isHidden = true
        musicPlayer = MusicPlayer()
    }
    
    func activatePlaybar(track: Any?) {
        switch track {
        case is SoundcloudTrack:
            let track = track as! SoundcloudTrack
            let streamURL = track.url
            musicPlayer.play(url: streamURL!)
        case is YouTubeVideo:
            playBarController.playbarArtwork.isHidden = true
            playBarController.youtubePreviewWebview.isHidden = false
            let track = track as! YouTubeVideo
            let embedURL = URL(string: "https://www.youtube.com/embed/\(track.videoID!)")
            playBarController.youtubePreviewWebview.loadRequest(URLRequest(url: embedURL!))
        default:
            print("Unable to play selected track.")
        }
        
        playBarView.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeTabBarVC = segue.destination as? HomeTabBarController {
            if let navController = homeTabBarVC.viewControllers?.first as? UINavigationController {
                let searchVC = navController.topViewController as! SearchViewController
                searchVC.baseDelegate = self
            }
        } else if let playBarVC = segue.destination as? PlayBarController {
            playBarController = playBarVC
        }
    }
}
