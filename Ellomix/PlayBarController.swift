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
    @IBOutlet weak var youtubePreviewWebview: UIWebView!
    @IBOutlet weak var placeholderView: UIView!
    
    override func viewDidLoad() {
        youtubePreviewWebview.isHidden = true
        youtubePreviewWebview.allowsInlineMediaPlayback = true
    }
}
