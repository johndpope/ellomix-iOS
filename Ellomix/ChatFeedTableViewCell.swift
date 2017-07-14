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
    
    @IBOutlet weak var fromRecipientLabel: UILabel!
    
    @IBOutlet weak var recentMessageLabel: UILabel!
    
    var chatId : String = ""
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
