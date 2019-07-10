//
//  CommentTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 7/6/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import Foundation

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var userProfilePictureImageView: RoundImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
