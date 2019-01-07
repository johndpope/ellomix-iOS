//
//  SearchTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 5/6/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class SearchTableViewMusicCell: UITableViewCell {
    
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var serviceIcon: UIImageView!
    @IBOutlet weak var optionsButton: UIButton!
    var track: Any! //TODO: Change to BaseTrack
    
}
