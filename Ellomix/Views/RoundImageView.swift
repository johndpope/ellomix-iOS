//
//  RoundImageView.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/19/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

class RoundImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.width / 2
        self.clipsToBounds = true
    }
    
}
