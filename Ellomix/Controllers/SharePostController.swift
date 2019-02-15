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
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    
    private var FirebaseAPI: FirebaseApi!
    var track: BaseTrack!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        
        captionTextView.textColor = UIColor.lightGray
        captionTextView.text = "Write a caption..."
        
        trackTitleLabel.text = track.title
        artistLabel.text = track.artist
        if let thumbnailUrl = track.thumbnailURL {
            artworkImage.downloadedFrom(link: thumbnailUrl)
        }
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Keyboard handling
    func handleKeyboardNotification(notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if (notification.name == Notification.Name.UIKeyboardWillShow) {
            view.frame.origin.y = -keyboardFrame.height
            if (captionTextView.textColor == UIColor.lightGray) {
                captionTextView.text = nil
                captionTextView.textColor = UIColor.black
            }
        } else {
            view.frame.origin.y = 0
            if (captionTextView.text.isEmpty) {
                captionTextView.text = "Write a caption..."
                captionTextView.textColor = UIColor.lightGray
            }
        }
    }
}
