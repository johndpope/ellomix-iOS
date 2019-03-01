//
//  PopUpPlayerController.swift
//  Ellomix
//
//  Created by Kevin Avila on 1/27/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit
import CoreMedia

class PopUpPlayerController: UIViewController {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var artistField: UILabel!
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet var timeDuration: UILabel!
    @IBOutlet var currentTime: UILabel!
    
    var currentTrack: Any?
    var playbar: PlayBarController?
    var selectUsersOrGroupsControllerNavController: UINavigationController!
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "SelectUsersOrGroups", bundle: nil)
        selectUsersOrGroupsControllerNavController = storyboard.instantiateViewController(withIdentifier: "selectUsersOrGroupsNavController") as? UINavigationController
    }

    override func viewWillAppear(_ animated: Bool) {
        loadTrackInfo()
        if (currentTrack is YouTubeVideo) {
            self.view.addSubview(Global.sharedGlobal.youtubePlayer!)
            Global.sharedGlobal.youtubePlayer?.frame = CGRect(x: 0, y: 125, width: self.view.frame.width, height: 272)
            if (Global.sharedGlobal.youtubePlayer?.playerState == YouTubePlayerState.Playing) {
                Global.sharedGlobal.youtubePlayer?.play()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (currentTrack is YouTubeVideo) {
            playbar?.reAddYoutubeVideo();
        }
    }

    func loadTrackInfo() {
        switch currentTrack {
        case is SpotifyTrack:
            Global.sharedGlobal.musicPlayer.setButton(button: playPauseButton)
            artworkImage.isHidden = false
            let track = currentTrack as! SpotifyTrack
            artworkImage.image = track.thumbnailImage
            titleField.text = track.title
            artistField.text = track.artist
        case is SoundcloudTrack:
            Global.sharedGlobal.musicPlayer.setButton(button: playPauseButton)
            artworkImage.isHidden = false
            let track = currentTrack as! SoundcloudTrack
            artworkImage.image = track.thumbnailImage
            titleField.text = track.title
            artistField.text = track.artist
            
            // Time duration
            if let duration = Global.sharedGlobal.musicPlayer.player?.currentItem?.duration {
                let progress = CMTimeGetSeconds(duration)
                let minutes = floor(progress / 60)
                let seconds = round(progress - minutes * 60)
                timeDuration.text = String(format:"%.0f:%02.0f", minutes, seconds)
            }
            
            // Current time progress
            let interval = CMTime(value: 1, timescale: 2)
            Global.sharedGlobal.musicPlayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                let progress = CMTimeGetSeconds(progressTime)
                let minutes = floor(progress / 60)
                let seconds = round(progress - minutes * 60)
                self.currentTime.text = String(format:"%.0f:%02.0f", minutes, seconds)
            })
        case is YouTubeVideo:
            Global.sharedGlobal.youtubePlayer?.setButton(button: playPauseButton)
            artworkImage.isHidden = true
            let track = currentTrack as! YouTubeVideo
            titleField.text = track.videoTitle
            artistField.text = track.videoChannel
            
            // Time duration
            if let duration = Int((Global.sharedGlobal.youtubePlayer?.getDuration())!) {
                let minutes = duration / 60
                let seconds = duration - minutes * 60
                timeDuration.text = String(format:"%0d:%.2d", minutes, seconds)
            }
            
            // Current time progress

        default:
            print("Unable to load track info.")
        }
    }
    
    @IBAction func playPause(_ sender: Any) {
        switch currentTrack {
        case is SpotifyTrack:
            Global.sharedGlobal.musicPlayer.playPause(button: playPauseButton)
        case is SoundcloudTrack:
            Global.sharedGlobal.musicPlayer.playPause(button: playPauseButton)
        case is YouTubeVideo:
            Global.sharedGlobal.youtubePlayer?.playPause(button: playPauseButton)
        default:
            print("Unable to play or pause current track.")
        }
    }
    
    @IBAction func shareTrackClicked(_ sender: Any) {
        let selectUsersOrGroupsVC = selectUsersOrGroupsControllerNavController.topViewController as! SelectUsersOrGroupsController
        selectUsersOrGroupsVC.currentTrack = currentTrack
        present(selectUsersOrGroupsControllerNavController, animated: true, completion: nil)
    }
    
    
    @IBAction func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if (sender.state == UIGestureRecognizerState.began) {
            initialTouchPoint = touchPoint
        } else if (sender.state == UIGestureRecognizerState.changed) {
            if (touchPoint.y - initialTouchPoint.y > 0) {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if (sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled) {
            if (touchPoint.y - initialTouchPoint.y > 100) {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
    @IBAction func dismissPlayer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
