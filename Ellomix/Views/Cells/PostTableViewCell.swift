//
//  PostTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/25/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var userProfilePicImageView: UIImageView!
    @IBOutlet weak var trackThumbnailButton: UIButton!
    
    var playIcon: UIImage!
    var pauseIcon: UIImage!
    var track: BaseTrack!

    override func awakeFromNib() {
        super.awakeFromNib()

        playIcon = #imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate)
        pauseIcon = #imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate)
        playPauseImageView.image = playIcon
        playPauseImageView.tintColor = UIColor.white
    }
    
    func playTrack() {
        playPauseImageView.image = pauseIcon
    }
    
    func pauseTrack() {
        playPauseImageView.image = playIcon
    }
}
