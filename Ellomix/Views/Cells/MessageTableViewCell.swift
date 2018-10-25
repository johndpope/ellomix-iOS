//
//  MessageTableViewCell.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/22/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.clear
        textView.layer.cornerRadius = 8
        
        return textView
    }()
    
    override func awakeFromNib() {
        addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.sizeToFit()
        textView.isScrollEnabled = false
        addConstraint(NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: userImageView, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: layoutMarginsGuide, attribute: .bottom, multiplier: 1, constant: 5))
        textView.widthAnchor.constraint(lessThanOrEqualToConstant: 230).isActive = true

    }
    
    func setupSentCell() {
        textView.backgroundColor = UIColor.ellomixBlue()
        addConstraint(NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: layoutMarginsGuide, attribute: .trailing, multiplier: 1, constant: 11))
    }
    
    func setupReceivedCell() {
        textView.backgroundColor = UIColor.ellomixLightGray()
        addConstraint(NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: userImageView, attribute: .trailing, multiplier: 1, constant: 8))
    }

}
