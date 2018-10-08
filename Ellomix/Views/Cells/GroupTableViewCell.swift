//
//  GroupTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/3/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var topRightImageView: UIImageView!
    @IBOutlet weak var bottomLeftImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var topRightImageLeadingConstraint: NSLayoutConstraint!
    
    var defaultTopRightImageLeadingConstant: CGFloat = 0
    var gid: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberLabel.isHidden = true
        defaultTopRightImageLeadingConstant = topRightImageLeadingConstraint.constant
    }
    
    override func prepareForReuse() {
        topRightImageLeadingConstraint.constant = defaultTopRightImageLeadingConstant
        numberLabel.isHidden = true
    }
}
