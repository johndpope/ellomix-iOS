//
//  SharePostController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/5/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit
import Firebase

class SharePostController: UIViewController {
    
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    private var FirebaseAPI: FirebaseApi!
    var track: BaseTrack!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        
        if let thumbnailUrl = track.thumbnailURL {
            artworkImage.downloadedFrom(link: thumbnailUrl)
        }
    }
}
