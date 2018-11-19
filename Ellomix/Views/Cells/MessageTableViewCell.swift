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
    
    var horizontalConstraint: NSLayoutConstraint!
    var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var lastType: String!
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.clear
        textView.layer.cornerRadius = 8
        
        return textView
    }()
    let trackPreview: TrackPreview = {
        let preview = TrackPreview()
        preview.contentView.translatesAutoresizingMaskIntoConstraints = false
        preview.contentView.layer.cornerRadius = 8
        
        return preview
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTextView()
    }
    
    override func prepareForReuse() {
        removeConstraint(horizontalConstraint)
        
        if (lastType == "track") {
            removeTrackPreview()
            addTextView()
        }
    }
        
    func setupSentCell(type: String) {
        if (type == "track") {
            removeTextView()
            addTrackPreview()
            horizontalConstraint = NSLayoutConstraint(item: trackPreview.contentView, attribute: .trailing, relatedBy: .equal, toItem: layoutMarginsGuide, attribute: .trailing, multiplier: 1, constant: 11)
            addConstraint(horizontalConstraint)
            trackPreview.contentView.backgroundColor = UIColor.ellomixBlue()
        } else {
            textView.backgroundColor = UIColor.ellomixBlue()
            horizontalConstraint = NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: layoutMarginsGuide, attribute: .trailing, multiplier: 1, constant: 11)
            addConstraint(horizontalConstraint)
        }
        
        lastType = type
    }
    
    func setupReceivedCell(type: String) {
        if (type == "track") {
            removeTextView()
            addTrackPreview()
            horizontalConstraint = NSLayoutConstraint(item: trackPreview.contentView, attribute: .leading, relatedBy: .equal, toItem: userImageView, attribute: .trailing, multiplier: 1, constant: 8)
            addConstraint(horizontalConstraint)
            trackPreview.contentView.backgroundColor = UIColor.ellomixLightGray()
        } else {
            textView.backgroundColor = UIColor.ellomixLightGray()
            horizontalConstraint = NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: userImageView, attribute: .trailing, multiplier: 1, constant: 8)
            addConstraint(horizontalConstraint)
        }
        
        lastType = type
    }
    
    func addTextView() {
        addSubview(textView)
        textView.sizeToFit()
        textView.isScrollEnabled = false
        topConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: userImageView, attribute: .top, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: layoutMarginsGuide, attribute: .bottom, multiplier: 1, constant: 5)
        addConstraint(topConstraint)
        addConstraint(bottomConstraint)
        textView.widthAnchor.constraint(lessThanOrEqualToConstant: 230).isActive = true
    }
    
    func removeTextView() {
        removeConstraint(topConstraint)
        removeConstraint(bottomConstraint)
        textView.widthAnchor.constraint(lessThanOrEqualToConstant: 230).isActive = false
        textView.removeFromSuperview()
    }
    
    func addTrackPreview() {
        addSubview(trackPreview)
        topConstraint = NSLayoutConstraint(item: trackPreview.contentView, attribute: .top, relatedBy: .equal, toItem: userImageView, attribute: .top, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: trackPreview.contentView, attribute: .bottom, relatedBy: .equal, toItem: layoutMarginsGuide, attribute: .bottom, multiplier: 1, constant: 5)
        addConstraint(topConstraint)
        addConstraint(bottomConstraint)
        trackPreview.contentView.widthAnchor.constraint(equalToConstant: 230).isActive = true
    }
    
    func removeTrackPreview() {
        removeConstraint(topConstraint)
        removeConstraint(bottomConstraint)
        trackPreview.contentView.widthAnchor.constraint(equalToConstant: 230).isActive = false
        trackPreview.removeFromSuperview()
    }

}
