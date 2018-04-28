//
//  ChatFeedTableViewCell.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/20/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class ChatFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var recentMessageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var firstProfileImageView: UIImageView!
    @IBOutlet weak var secondProfileImageView: UIImageView!
    
    var gid: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
