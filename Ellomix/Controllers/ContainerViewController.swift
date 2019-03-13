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
    private var queue = [Dictionary<String, AnyObject>]()
    private var queueIndex: Int!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        playBarView.isHidden = true
        playBarController.placeholderView.isHidden = true
        Global.sharedGlobal.musicPlayer.baseDelegate = self
    }
    
    func playQueue(queue: [Dictionary<String, AnyObject>], startingIndex: Int) {
        self.queue = queue
        queueIndex = startingIndex
        queueTrack()
    }
    
    func queueTrack() {
        let track = queue[queueIndex]
        
        switch track["source"] as! String {
        case "spotify":
            let spTrack = SpotifyTrack()
            spTrack.artist = track["artist"] as? String
            spTrack.title = track["title"] as? String
            spTrack.id = track["id"] as? String
            let artworkUrl = track["thumbnail_url"] as? String
            
            if (artworkUrl == nil) {
                spTrack.thumbnailImage = #imageLiteral(resourceName: "ellomix_logo_bw")
            } else {
                spTrack.thumbnailURL = NSURL(string: artworkUrl!) as URL?
                let imageData = try! Data(contentsOf: spTrack.thumbnailURL!)
                spTrack.thumbnailImage = UIImage(data: imageData)
            }
            
            activatePlaybar(track: spTrack)
        case "soundcloud":
            let scTrack = SoundcloudTrack()
            scTrack.artist = track["artist"] as? String
            scTrack.title = track["title"] as? String
            scTrack.url = NSURL(string: track["id"] as! String) as URL?
            let artworkUrl = track["thumbnail_url"] as? String
            
            if (artworkUrl == nil) {
                scTrack.thumbnailImage = #imageLiteral(resourceName: "ellomix_logo_bw")
            } else {
                scTrack.thumbnailURL = NSURL(string: artworkUrl!) as URL?
                let imageData = try! Data(contentsOf: scTrack.thumbnailURL!)
                scTrack.thumbnailImage = UIImage(data: imageData)
            }
            
            activatePlaybar(track: scTrack)
        case "youtube":
            let ytVideo = YouTubeVideo()
            
            ytVideo.videoChannel = track["artist"] as? String
            ytVideo.videoTitle = track["title"] as? String
            ytVideo.videoID = track["id"] as? String
            ytVideo.videoThumbnailURL = track["thumbnail_url"] as? String
            
            activatePlaybar(track: ytVideo)
        default:
            print("Unable to play queue.")
        }
    }
    
    func playTrack(track: Any?) {
        queue = []
        queueIndex = 0
        activatePlaybar(track: track)
    }
    
    private func activatePlaybar(track: Any?) {
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
        
        switch track {
        case is SpotifyTrack:
            playBarController.playbarArtwork.isHidden = false
            Global.sharedGlobal.youtubePlayer?.isHidden = true
            let track = track as! SpotifyTrack
            playBarController.currentTrack = track
            let id = track.id
            Global.sharedGlobal.spotifyPlayer.play(id: id!)
            // Global.sharedGlobal.musicPlayer.updateNowPlayingInfoCenter(track: track)
            playBarController.playbarTitle.text = track.title
            playBarController.playbarArtist.text = track.artist
            playBarController.playbarArtwork.image = track.thumbnailImage
            
            let recentlyListenedValues = ["artist": track.artist, "title": track.title, "thumbnail_url": track.thumbnailURL?.absoluteString, "id": track.id, "source": "spotify"] as [String : AnyObject]
            FirebaseAPI.getUsersRef().child((Global.sharedGlobal.user?.uid)!).child("recently_listened").childByAutoId().updateChildValues(recentlyListenedValues)
            
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
            
            let recentlyListenedValues = ["artist": track.artist, "title": track.title, "thumbnail_url": track.thumbnailURL?.absoluteString, "id": track.url?.absoluteString, "source": "soundcloud"] as [String : AnyObject]
            FirebaseAPI.getUsersRef().child((Global.sharedGlobal.user?.uid)!).child("recently_listened").childByAutoId().updateChildValues(recentlyListenedValues)
    
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
            
            let recentlyListenedValues = ["artist": track.videoChannel, "title": track.videoTitle, "thumbnail_url": track.videoThumbnailURL, "id": track.videoID, "source": "youtube"] as [String : AnyObject]
            FirebaseAPI.getUsersRef().child((Global.sharedGlobal.user?.uid)!).child("recently_listened").childByAutoId().updateChildValues(recentlyListenedValues)
        default:
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
                let chatFeedVC = navController.topViewController as! ChatFeedTableViewController
                chatFeedVC.baseDelegate = self
            }
            if let navController = homeTabBarVC.viewControllers?[3] as? UINavigationController {
                let profileVC = navController.topViewController as! ProfileController
                profileVC.baseDelegate = self
            }
        } else if let playBarVC = segue.destination as? PlayBarController {
            playBarController = playBarVC
        }
    }
}
