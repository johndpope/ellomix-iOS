//
//  SentChatTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 3/25/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SentChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
