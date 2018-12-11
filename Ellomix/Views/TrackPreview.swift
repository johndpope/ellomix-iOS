//
//  TrackPreview.swift
//  Ellomix
//
//  Created by Kevin Avila on 11/7/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

@IBDesignable

class TrackPreview: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var trackThumbnail: UIImageView!
    @IBOutlet weak var serviceIcon: UIImageView!
    @IBOutlet weak var playPauseIcon: UIImageView!
    
    var playIcon: UIImage!
    var pauseIcon: UIImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TrackPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        playIcon = #imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate)
        pauseIcon = #imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate)
        playPauseIcon.image = playIcon
        playPauseIcon.tintColor = UIColor.white
    }
    
    func isPlaying() -> Bool {
        return playPauseIcon.image == playIcon
    }
    
    func play() {
        playPauseIcon.image = playIcon
    }
    
    func pause() {
        playPauseIcon.image = pauseIcon
    }
}
