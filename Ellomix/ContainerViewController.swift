//
//  ContainerViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import AVFoundation

class ContainerViewController: UIViewController, YouTubePlayerDelegate {
    
    @IBOutlet weak var playBarView: UIView!
    
    var playBarController: PlayBarController!
    private var FirebaseAPI: FirebaseApi!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        playBarView.isHidden = true
        playBarController.placeholderView.isHidden = true
    }
    
    func activatePlaybar(track: Any?) {
        if (playBarController.currentTrack is YouTubeVideo) {
            Global.sharedGlobal.youtubePlayer?.stop()
        } else if (Global.sharedGlobal.musicPlayer.isPlaying()) {
            Global.sharedGlobal.musicPlayer.player?.pause()
        }
        
        switch track {
        case is SoundcloudTrack:
            playBarController.playbarArtwork.isHidden = false
            Global.sharedGlobal.youtubePlayer?.isHidden = true
            let track = track as! SoundcloudTrack
            playBarController.currentTrack = track
            let streamURL = track.url
            Global.sharedGlobal.musicPlayer.play(url: streamURL!)
            Global.sharedGlobal.musicPlayer.updateNowPlayingInfoCenter(track: track)
            playBarController.playbarTitle.text = track.title
            playBarController.playbarArtist.text = track.artist
            playBarController.playbarArtwork.image = track.thumbnailImage
            
            let id = track.id
            let timestamp:Int = Int(Date.timeIntervalSinceReferenceDate)
            let recentlyListenedValues = ["type": "soundcloud", "timestamp": timestamp] as [String : AnyObject]
            FirebaseAPI.getUsersRef().child((Global.sharedGlobal.user?.uid)!).child("recently_listened").child(id!).updateChildValues(recentlyListenedValues)
        case is YouTubeVideo:
            playBarController.playbarArtwork.isHidden = true
            let track = track as! YouTubeVideo
            playBarController.currentTrack = track
            Global.sharedGlobal.youtubePlayer = YouTubePlayerView()
            Global.sharedGlobal.youtubePlayer?.delegate = self
            Global.sharedGlobal.youtubePlayer?.playerVars =
                ["playsinline": 1 as AnyObject,
                 "showinfo": 0 as AnyObject,
                 "rel": 0 as AnyObject,
                 "modestbranding": 1 as AnyObject,
                 "controls": 0 as AnyObject]
            Global.sharedGlobal.youtubePlayer?.loadVideoID(track.videoID!)
            playBarController.view.addSubview(Global.sharedGlobal.youtubePlayer!)
            Global.sharedGlobal.youtubePlayer?.frame = CGRect(x: 0, y: 0, width: 113, height: playBarController.view.frame.height)
            playBarController.playbarTitle.text = track.videoTitle
            playBarController.playbarArtist.text = track.videoChannel
            
            let timestamp:Int = Int(Date.timeIntervalSinceReferenceDate)
            let recentlyListenedValues = ["type": "youtube", "timestamp": timestamp] as [String : AnyObject]
            FirebaseAPI.getUsersRef().child((Global.sharedGlobal.user?.uid)!).child("recently_listened").child(track.videoID!).updateChildValues(recentlyListenedValues)
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
