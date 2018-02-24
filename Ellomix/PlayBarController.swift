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
    var popUpPlayer: PopUpPlayerController?
    var currentTrack: Any?
    //let transition = PopUpAnimator()
    
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        popUpPlayer = storyboard.instantiateViewController(withIdentifier: "popUpPlayerController") as? PopUpPlayerController
//        transition.dismissCompletion = {
//            self.view.isHidden = false
//        }
    }

    @IBAction func playPause(_ sender: Any) {
        switch currentTrack {
        case is SoundcloudTrack:
            Global.sharedGlobal.musicPlayer.playPause(button: playPauseButton)
        case is YouTubeVideo:
            if (Global.sharedGlobal.youtubePlayer?.playerState == YouTubePlayerState.Playing) {
                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                Global.sharedGlobal.youtubePlayer?.pause()
            } else {
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                Global.sharedGlobal.youtubePlayer?.play()
            }
        default:
            print("Unable to play or pause current track.")
        }
    }

    @IBAction func playbarTapped(_ sender: Any) {
        //popUpPlayer.transitioningDelegate = self
        popUpPlayer?.currentTrack = currentTrack
        popUpPlayer?.playbar = self
        self.present(popUpPlayer!, animated: true, completion: nil)
    }

    func reAddYoutubeVideo() {
        self.view.addSubview(Global.sharedGlobal.youtubePlayer!)
        Global.sharedGlobal.youtubePlayer?.frame = CGRect(x: 0, y: 0, width: 113, height: self.view.frame.height)
        Global.sharedGlobal.youtubePlayer?.play()
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
