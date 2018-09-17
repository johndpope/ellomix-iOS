//
//  SearchHeaderCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 3/3/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SearchHeaderCell: UITableViewCell {
    
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    var buttonAction: ((Any) -> Void)?
    
    @IBAction func seeAllButtonPressed(_ sender: Any) {
        self.buttonAction?(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
