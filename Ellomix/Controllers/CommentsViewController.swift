//
//  PostDetailController.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/27/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit
import Foundation

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var dockView: UIView!
    @IBOutlet weak var profilePictureImageView: RoundImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var dockBottomConstraint: NSLayoutConstraint!
    
    private var FirebaseAPI: FirebaseApi!
    private var currentUser: EllomixUser!
    private var notificationService: NotificationService!
    var post: Post!
    var newComment: Bool = false
    
    var comments = [Comment]()
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        notificationService = NotificationService()
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.estimatedRowHeight = 40
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        
        commentTextView.delegate = self
        commentTextView.layer.cornerRadius = 8.0
        commentTextView.text = "Add a comment"
        commentTextView.textColor = UIColor.lightGray
        commentTextView.sizeToFit()
        
        profilePictureImageView.downloadedFrom(link: currentUser.profilePicLink)
        
        self.hideKeyboardWhenTappedAround()
        
        commentsTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseAPI.getPostComments(pid: post.pid, completion: { (comments) in
            self.comments = comments
            self.commentsTableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if (newComment) {
            commentTextView.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func postButtonClicked(_ sender: Any) {
        if (!commentTextView.text.isEmpty) {
            let comment = Comment()
            
            comment.uid = currentUser.uid
            comment.name = currentUser.name
            comment.photoUrl = currentUser.profilePicLink
            comment.timestamp = Int(Date().timeIntervalSince1970)
            comment.comment = commentTextView.text
            
            FirebaseAPI.postComment(post: post, comment: comment)
            comments.append(comment)
            commentsTableView.reloadData()
            commentTextView.text = ""
            
            // Send notification
            notificationService.sendNewCommentNotification(commenter: currentUser, post: post, comment: comment)
            
            // Update comment count
            //TODO: Implement comment deletion and a way for the TL to update the count correctly on back navigation
            post.comments = post.comments + 1
        }
    }
    
    //MARK: Keyboard handling
    
    @objc func handleKeyboardNotification(notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if (notification.name == Notification.Name.UIKeyboardWillShow) {
            dockBottomConstraint.constant = keyboardFrame.height
            if (commentTextView.textColor == UIColor.lightGray) {
                commentTextView.text = nil
                commentTextView.textColor = UIColor.black
            }
        } else {
            dockBottomConstraint.constant = 0
            commentsTableView.contentOffset.y -= keyboardFrame.height
            if (commentTextView.text.isEmpty) {
                commentTextView.text = "Add a comment"
                commentTextView.textColor = UIColor.lightGray
            }
        }
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            if (notification.name == Notification.Name.UIKeyboardWillShow) {
                self.commentsTableView.contentOffset.y += keyboardFrame.height
            }
        }, completion: nil)
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row]
        
        let nameString = NSMutableAttributedString(string: "\(comment.name!)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
        let commentString = NSAttributedString(string: " \(comment.comment!)")
        nameString.append(commentString)
        cell.commentTextView.attributedText = nameString
        
        let timestampDate = Date(timeIntervalSince1970: Double(comment.timestamp))
        cell.timestampLabel.text = timestampDate.timeAgoDisplay()
        
        cell.userProfilePictureImageView.downloadedFrom(link: comment.photoUrl)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension CommentsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if commentTextView.contentSize.height >= 100 {
            commentTextView.isScrollEnabled = true
        } else {
            commentTextView.frame.size.height = commentTextView.contentSize.height
            commentTextView.isScrollEnabled = false
        }
    }
}
