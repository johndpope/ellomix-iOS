//
//  GroupPlaylistControlsTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 9/4/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class GroupPlaylistControlsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playButton.backgroundColor = UIColor.ellomixBlue()
        playButton.circular()
        playButton.setTitleColor(UIColor.white, for: .normal)
        shuffleButton.backgroundColor = UIColor.ellomixBlue()
        shuffleButton.circular()
        shuffleButton.setTitleColor(UIColor.white, for: .normal)
    }
    
}
