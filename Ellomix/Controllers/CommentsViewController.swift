//
//  PostDetailController.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/27/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var dockView: UIView!
    @IBOutlet weak var profilePictureImageView: RoundImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var dockBottomConstraint: NSLayoutConstraint!
    
    private var FirebaseAPI: FirebaseApi!
    private var currentUser: EllomixUser!
    var pid: String!
    
    var comments = [Comment]()
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        
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
        
        commentsTableView.register(UINib(nibName: "CommentViewCell", bundle: nil), forCellReuseIdentifier: "commentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseAPI.getPostComments(pid: pid, completion: { (comments) in
            self.comments = comments
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func postButtonClicked(_ sender: Any) {
        
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
                commentTextView.text = "Reply"
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