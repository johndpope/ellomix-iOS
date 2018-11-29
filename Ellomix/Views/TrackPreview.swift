//
//  TrackPreview.swift
//  Ellomix
//
//  Created by Kevin Avila on 11/7/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

@IBDesignable

class TrackPreview: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var trackThumbnail: UIImageView!
    @IBOutlet weak var serviceIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TrackPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
    }
}
