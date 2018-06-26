//
//  ComposeMessageTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 11/2/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class ComposeMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfilePic.circular()
    }

}
