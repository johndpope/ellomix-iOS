//
//  PopUpPlayerController.swift
//  Ellomix
//
//  Created by Kevin Avila on 1/27/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit
import CoreMedia

class PopUpPlayerController: UIViewController, SharePostDelegate {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var artistField: UILabel!
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet var timeDuration: UILabel!
    @IBOutlet var currentTime: UILabel!
    
    var currentTrack: BaseTrack!
    var playbar: PlayBarController?
    var selectUsersOrGroupsControllerNavController: UINavigationController!
    var sharePostNavController: UINavigationController!
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidLoad() {        
        let selectUsersOrGroupsStoryboard = UIStoryboard(name: "SelectUsersOrGroups", bundle: nil)
        let sharePostStoryboard = UIStoryboard(name: "SharePost", bundle: nil)
        
        selectUsersOrGroupsControllerNavController = selectUsersOrGroupsStoryboard.instantiateViewController(withIdentifier: "selectUsersOrGroupsNavController") as? UINavigationController
        sharePostNavController = sharePostStoryboard.instantiateViewController(withIdentifier: "sharePostNavController") as? UINavigationController
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
            Global.sharedGlobal.spotifyPlayer.setButton(button: playPauseButton)
            artworkImage.isHidden = false
            artworkImage.image = currentTrack.thumbnailImage
            titleField.text = currentTrack.title
            artistField.text = currentTrack.artist
        case is SoundcloudTrack:
            Global.sharedGlobal.musicPlayer.setButton(button: playPauseButton)
            artworkImage.isHidden = false
            artworkImage.image = currentTrack.thumbnailImage
            titleField.text = currentTrack.title
            artistField.text = currentTrack.artist
            
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
            titleField.text = currentTrack.title
            artistField.text = currentTrack.artist

            // Time duration
            if let durationStr = Global.sharedGlobal.youtubePlayer?.getDuration() {
                if let duration:Double = Double(durationStr) {
                    let minutes = floor(duration / 60)
                    let seconds = round(duration - minutes * 60)
                    timeDuration.text = String(format:"%.0f:%02.0f", minutes, seconds)
                }
            }
            
            // Current time progress
            if #available(iOS 10.0, *) {
                let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    RunLoop.current.add(timer, forMode: .commonModes)
                    timer.tolerance = 0.1
                    if let timeStr = Global.sharedGlobal.youtubePlayer?.getCurrentTime() {
                        if let time:Double = Double(timeStr) {
                            let minutes = floor(time / 60)
                            let seconds = round(time - minutes * 60)
                            self.currentTime.text = String(format:"%.0f:%02.0f", minutes, seconds)
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        default:
            print("Unable to load track info.")
        }
    }
    
    @IBAction func playPause(_ sender: Any) {
        switch currentTrack {
        case is SpotifyTrack:
            Global.sharedGlobal.spotifyPlayer.playPause(button: playPauseButton)
        case is SoundcloudTrack:
            Global.sharedGlobal.musicPlayer.playPause(button: playPauseButton)
        case is YouTubeVideo:
            Global.sharedGlobal.youtubePlayer?.playPause(button: playPauseButton)
        default:
            print("Unable to play or pause current track.")
        }
    }
    
    @IBAction func showShareOptions(_ sender: Any) {
        var actions = [UIAlertAction]()
        
        let postAction = UIAlertAction(title: "Create Post", style: .default) { _ in
            let sharePostVC = self.sharePostNavController.topViewController as! SharePostController
            
            sharePostVC.track = self.currentTrack
            sharePostVC.showCancelButton = true
            sharePostVC.sharePostDelegate = self
            self.present(self.sharePostNavController, animated: true, completion: nil)
        }
        let shareAction = UIAlertAction(title: "Send to Friends", style: .default) { _ in
            let selectUsersOrGroupsVC = self.selectUsersOrGroupsControllerNavController.topViewController as! SelectUsersOrGroupsController
            selectUsersOrGroupsVC.currentTrack = self.currentTrack
            self.present(self.selectUsersOrGroupsControllerNavController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actions.append(postAction)
        actions.append(shareAction)
        actions.append(cancelAction)
        EllomixAlertController.showActionSheet(viewController: self, actions: actions)
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
    
    //MARK: SharePostDelegate
    func didSharePost(sharePostVC: SharePostController) {
        sharePostVC.dismiss(animated: true, completion: nil)
    }
    
}
