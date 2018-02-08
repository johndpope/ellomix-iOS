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
        musicPlayer = MusicPlayer()
    }
    
    func activatePlaybar(track: Any?) {
        switch track {
        case is SoundcloudTrack:
            playBarController.playbarArtwork.isHidden = false
            let track = track as! SoundcloudTrack
            playBarController.currentTrack = track
            let streamURL = track.url
            musicPlayer.play(url: streamURL!)
            playBarController.playbarTitle.text = track.title
            playBarController.playbarArtist.text = track.artist
            playBarController.playbarArtwork.image = track.thumbnailImage
        case is YouTubeVideo:
            playBarController.playbarArtwork.isHidden = true
            let track = track as! YouTubeVideo
            playBarController.currentTrack = track

            if (Global.sharedGlobal.youtubePlayer?.playerState == YouTubePlayerState.Playing) {
                Global.sharedGlobal.youtubePlayer?.stop()
            }
            Global.sharedGlobal.youtubePlayer = YouTubePlayerView()
            Global.sharedGlobal.youtubePlayer?.delegate = self
            Global.sharedGlobal.youtubePlayer?.playerVars =
                ["playsinline": 1 as AnyObject,
                 "showinfo": 0 as AnyObject,
                 "rel": 0 as AnyObject,
                 "modestbranding": 1 as AnyObject,
                 "controls": 0 as AnyObject]
            Global.sharedGlobal.youtubePlayer?.loadVideoID(track.videoID!)
            self.playBarController.view.addSubview(Global.sharedGlobal.youtubePlayer!)
            Global.sharedGlobal.youtubePlayer?.frame = CGRect(x: 0, y: 0, width: 113, height: self.playBarController.view.frame.height)

            playBarController.playbarTitle.text = track.videoTitle
            playBarController.playbarArtist.text = track.videoChannel
        default:
            print("Unable to play selected track.")
        }
        
        playBarView.isHidden = false
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        Global.sharedGlobal.youtubePlayer?.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeTabBarVC = segue.destination as? HomeTabBarController {
            playBarView.transform = playBarView.transform.translatedBy(x: 0, y: -homeTabBarVC.tabBar.frame.height)
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
