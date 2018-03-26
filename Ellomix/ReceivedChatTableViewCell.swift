//
//  ChatTableViewCell.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/22/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class RecievedChatTableViewCell: UITableViewCell {
    
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
