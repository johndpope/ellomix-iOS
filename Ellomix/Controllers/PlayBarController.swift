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
    var popUpPlayer: PopUpPlayerController!
    var currentTrack: BaseTrack!
    //let transition = PopUpAnimator()
    
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "PopUpPlayer", bundle: nil)
        popUpPlayer = storyboard.instantiateViewController(withIdentifier: "popUpPlayerController") as? PopUpPlayerController
//        transition.dismissCompletion = {
//            self.view.isHidden = false
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch currentTrack {
        case is SpotifyTrack:
            Global.sharedGlobal.spotifyPlayer.setButton(button: playPauseButton)
        case is SoundcloudTrack:
            Global.sharedGlobal.musicPlayer.setButton(button: playPauseButton)
        case is YouTubeVideo:
            Global.sharedGlobal.youtubePlayer?.setButton(button: playPauseButton)
        default:
            print("Failed initializing play bar.")
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

    @IBAction func playbarTapped(_ sender: Any) {
        //popUpPlayer.transitioningDelegate = self
        popUpPlayer.currentTrack = currentTrack
        popUpPlayer.playbar = self
        self.present(popUpPlayer!, animated: true, completion: nil)
    }

    func reAddYoutubeVideo() {
        self.view.addSubview(Global.sharedGlobal.youtubePlayer!)
        Global.sharedGlobal.youtubePlayer?.frame = CGRect(x: 0, y: 0, width: 113, height: self.view.frame.height)
        if (Global.sharedGlobal.youtubePlayer?.playerState == YouTubePlayerState.Playing) {
            Global.sharedGlobal.youtubePlayer?.play()
        }
    }

    // Transition Delegate functions

//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.originFrame = self.view.convert(self.view.frame, to: nil)
//        transition.presenting = true
//        self.view.isHidden = true
//
//        return transition
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.presenting = false
//
//        return transition
//    }
}
