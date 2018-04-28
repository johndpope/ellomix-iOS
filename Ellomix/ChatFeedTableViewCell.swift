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
    @IBOutlet weak var profileImageLabel: UILabel!
    @IBOutlet weak var secondProfileImageLeadingConstraint: NSLayoutConstraint!
    
    var defaultSecondProfileLeadingConstant: CGFloat = 0
    
    var gid: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageLabel.isHidden = true
        self.selectionStyle = .none
        defaultSecondProfileLeadingConstant = secondProfileImageLeadingConstraint.constant
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.contentView.backgroundColor = selected ? UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0) : nil
    }
    
    override func prepareForReuse() {
        secondProfileImageLeadingConstraint.constant = defaultSecondProfileLeadingConstant
    }

}
