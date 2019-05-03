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
    @IBOutlet weak var playBarViewBottomConstraint: NSLayoutConstraint!
    
    var playBarController: PlayBarController!
    private var FirebaseAPI: FirebaseApi!
    private var scService: SoundcloudService!
    private var queue = [BaseTrack]()
    private var queueIndex: Int!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        scService = SoundcloudService()

        playBarView.isHidden = true
        playBarController.placeholderView.isHidden = true
        Global.sharedGlobal.musicPlayer.baseDelegate = self
    }
    
    func playQueue(queue: [BaseTrack], startingIndex: Int) {
        self.queue = queue
        queueIndex = startingIndex
        queueTrack()
    }
    
    func queueTrack() {
        let track = queue[queueIndex]

        determineSourceTrack(baseTrack: track)
    }
    
    func playTrack(track: BaseTrack) {
        queue = []
        queueIndex = 0

        determineSourceTrack(baseTrack: track)
    }
    
    private func activatePlaybar(track: BaseTrack) {
        if (AVAudioSession.sharedInstance().category != AVAudioSessionCategoryPlayback) {
            let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            let _ = try? AVAudioSession.sharedInstance().setActive(true)
        }
        
        if (Global.sharedGlobal.spotifyPlayer.isPlaying()) {
            Global.sharedGlobal.spotifyPlayer.pause()
        } else if (playBarController.currentTrack is YouTubeVideo) {
            Global.sharedGlobal.youtubePlayer?.stop()
        } else if (Global.sharedGlobal.musicPlayer.isPlaying()) {
            Global.sharedGlobal.musicPlayer.player?.pause()
        }
        
        if let spTrack = track as? SpotifyTrack {
            playBarController.playbarArtwork.isHidden = false
            playBarController.currentTrack = spTrack
            Global.sharedGlobal.spotifyPlayer.play(id: spTrack.id)
            // Global.sharedGlobal.musicPlayer.updateNowPlayingInfoCenter(track: track)
            playBarController.playbarTitle.text = spTrack.title
            playBarController.playbarArtist.text = spTrack.artist
            playBarController.playbarArtwork.image = spTrack.thumbnailImage
            
            FirebaseAPI.updateRecentlyListened(track: spTrack)
        } else if let scTrack = track as? SoundcloudTrack {
            playBarController.playbarArtwork.isHidden = false
            Global.sharedGlobal.youtubePlayer?.isHidden = true
            playBarController.currentTrack = scTrack
            Global.sharedGlobal.musicPlayer.play(url: scTrack.url)
            Global.sharedGlobal.musicPlayer.updateNowPlayingInfoCenter(track: scTrack)
            playBarController.playbarTitle.text = scTrack.title
            playBarController.playbarArtist.text = scTrack.artist
            playBarController.playbarArtwork.image = scTrack.thumbnailImage
            
            FirebaseAPI.updateRecentlyListened(track: scTrack)
        } else if let ytVideo = track as? YouTubeVideo {
            playBarController.playbarArtwork.isHidden = true
            playBarController.currentTrack = ytVideo
            Global.sharedGlobal.youtubePlayer = YouTubePlayerView()
            Global.sharedGlobal.youtubePlayer?.delegate = self
            Global.sharedGlobal.youtubePlayer?.playerVars =
                ["playsinline": 1 as AnyObject,
                 "showinfo": 0 as AnyObject,
                 "rel": 0 as AnyObject,
                 "modestbranding": 1 as AnyObject,
                 "controls": 0 as AnyObject]
            Global.sharedGlobal.youtubePlayer?.loadVideoID(ytVideo.id)
            playBarController.view.addSubview(Global.sharedGlobal.youtubePlayer!)
            Global.sharedGlobal.youtubePlayer?.frame = CGRect(x: 0, y: 0, width: 113, height: playBarController.view.frame.height)
            playBarController.playbarTitle.text = ytVideo.title
            playBarController.playbarArtist.text = ytVideo.artist
            
            FirebaseAPI.updateRecentlyListened(track: ytVideo)
        } else {
            print("Unable to play selected track.")
        }
        
        playBarView.isHidden = false
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        Global.sharedGlobal.youtubePlayer?.play()
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if (playerState == YouTubePlayerState.Ended) {
            queueIndex = queueIndex + 1
            if (queueIndex < queue.count) {
                queueTrack()
            }
        }
    }
    
    public func musicPlayerFinishedPlaying(sender: NSNotification) {
        queueIndex = queueIndex + 1
        if (queueIndex < queue.count) {
            queueTrack()
        }
    }
    
    func determineSourceTrack(baseTrack: BaseTrack) {
        if (baseTrack is SpotifyTrack || baseTrack is SoundcloudTrack || baseTrack is YouTubeVideo) {
            activatePlaybar(track: baseTrack)
        } else {
            switch baseTrack.source {
            case "spotify":
                let spTrack = SpotifyTrack(baseTrack: baseTrack)

                spTrack.downloadImage()
                activatePlaybar(track: spTrack)
            case "soundcloud":
                let scTrack = SoundcloudTrack(baseTrack: baseTrack)
                
                scTrack.downloadImage()
                scService.getTrackById(id: Int(baseTrack.id)!) { (track) -> () in
                    scTrack.url = track.streamURL

                    self.activatePlaybar(track: scTrack)
                }
            case "youtube":
                let ytVideo = YouTubeVideo(baseTrack: baseTrack)
                
                activatePlaybar(track: ytVideo)
            default:
                print("Loaded track has no source type.")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeTabBarVC = segue.destination as? HomeTabBarController {
            playBarView.transform = playBarView.transform.translatedBy(x: 0, y: -homeTabBarVC.tabBar.frame.height)
            if let navController = homeTabBarVC.viewControllers?[0] as? UINavigationController {
                let timelineVC = navController.topViewController as! TimelineTableViewController
                timelineVC.baseDelegate = self
            }
            if let navController = homeTabBarVC.viewControllers?[1] as? UINavigationController {
                let searchVC = navController.topViewController as! SearchViewController
                searchVC.baseDelegate = self
            }
            if let navController = homeTabBarVC.viewControllers?[2] as? UINavigationController {
                let postVC = navController.topViewController as! SearchSongsTableViewController
                homeTabBarVC.searchSongsNavController = navController
                postVC.searchSongsDelegate = homeTabBarVC
                postVC.selectLimit = 1
            }
            if let navController = homeTabBarVC.viewControllers?[3] as? UINavigationController {
                let chatFeedVC = navController.topViewController as! ChatFeedTableViewController
                chatFeedVC.baseDelegate = self
            }
            if let navController = homeTabBarVC.viewControllers?[4] as? UINavigationController {
                let profileVC = navController.topViewController as! ProfileController
                profileVC.baseDelegate = self
            }
        } else if let playBarVC = segue.destination as? PlayBarController {
            playBarController = playBarVC
        }
    }
}
