//
//  SharePostController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/5/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit
import Firebase

class SharePostController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var captionTextView: UITextView!
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser!
    var track: BaseTrack!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        
        captionTextView.delegate = self
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
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        let post = Post()
        
        post.uid = currentUser.uid
        post.name = currentUser.name
        post.photoUrl = currentUser.profilePicLink
        post.track = track
        post.comments = 0
        post.likes = 0
        post.timestamp = Int(Date().timeIntervalSince1970)
        post.caption = captionTextView.text
        
        FirebaseAPI.sharePost(post: post)
        
        let alertTitle = "Shared!"
        let alertMessage = "Shared song to followers"
        EllomixAlertController.showAlert(viewController: self, title: alertTitle, message: alertMessage, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        })
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
    
    //MARK: TextView

    // Text limit for caption
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let charLimit = 2200;
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count

        return numberOfChars < charLimit;
    }

}
