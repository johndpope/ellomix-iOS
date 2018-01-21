//
//  ContainerViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, YouTubePlayerDelegate {
    
    
    @IBOutlet weak var playBarView: UIView!
    
    private var musicPlayer: MusicPlayer!
    var playBarController: PlayBarController!
    
    override func viewDidLoad() {
        playBarView.isHidden = true
        playBarController.placeholderView.isHidden = true
        playBarController.youtubePlayer.delegate = self
        musicPlayer = MusicPlayer()
    }
    
    func activatePlaybar(track: Any?) {
        switch track {
        case is SoundcloudTrack:
            let track = track as! SoundcloudTrack
            playBarController.currentTrack = track
            let streamURL = track.url
            musicPlayer.play(url: streamURL!)
        case is YouTubeVideo:
            playBarController.playbarArtwork.isHidden = true
            playBarController.youtubePlayer.isHidden = false
            let track = track as! YouTubeVideo
            playBarController.currentTrack = track
            playBarController.youtubePlayer.loadVideoID(track.videoID!)
            playBarController.playbarTitle.text = track.videoTitle
            playBarController.playbarArtist.text = track.videoChannel
        default:
            print("Unable to play selected track.")
        }
        
        playBarView.isHidden = false
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        videoPlayer.play()
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}
