//
//  ChatViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/21/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var dockView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dockBottomConstraint: NSLayoutConstraint!
    
    private var FirebaseAPI: FirebaseApi!
    private var messagesRefHandle: DatabaseHandle?
    var currentUser:EllomixUser?
    var gid: String?
    var newChatGroup: [Dictionary<String, AnyObject>?]?
    
    var messages = [Dictionary<String, AnyObject>?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.isScrollEnabled = true
        messageTextView.delegate = self
        
        messageTextView.layer.cornerRadius = 8.0
        messageTextView.text = "Reply"
        messageTextView.textColor = UIColor.lightGray
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if (gid == nil) {
            // Check for existing group between newChatGroup and current user.
            FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
//                let gid = snapshot.key
//
//                self.FirebaseAPI.getGroupsRef().observeSingleEvent(of: .value, with: { (snapshot) in
//                    if (snapshot.hasChild(gid)) {
//                        self.gid = gid
//                        self.observeMessages()
//                    }
//                })
            })
        } else {
            observeMessages()
        }
    }
    
    deinit {
        if let refHandle = messagesRefHandle {
            FirebaseAPI.getMessagesRef().child(gid!).removeObserver(withHandle: refHandle)
        }
    }

    func observeMessages() {
        messagesRefHandle = FirebaseAPI.getMessagesRef().child(gid!).observe(.childAdded, with: { (snapshot)  in
            let message = snapshot.value as? Dictionary<String, AnyObject>
            self.messages.append(message)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // UITableViewDataSource protocol methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatTableViewCell
        
        // Unpack message from Firebase DataSnapshot
//        let message = self.messages[indexPath.row]
//        guard let message = messageSnapshot.value as? [String:String] else { return cell }
//
//        let name = message["name"] ?? ""
//        let text = message["text"] ?? ""
//
//        cell.recipientLabel.text = name
//        cell.messageLabel.text = text
//        cell.imageView?.image = UIImage(named: "ic_account_circle")
//        if let photoURL = message["photoUrl"], let URL = URL(string: photoURL),
//            let data = try? Data(contentsOf: URL) {
//            cell.imageView?.image = UIImage(data: data)
//        }
//        return cell
        return UITableViewCell()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        if (!messageTextView.text.isEmpty) {
            if (gid != nil) {
                sendMessage(message: messageTextView.text)
            } else {
                
                FirebaseAPI.getGroupsRef().childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
                    self.gid = snapshot.key
                    
                    var groupName = ""
                    var usersData = [String: AnyObject]()
                    for user in self.newChatGroup! {
                        usersData[user!["uid"] as! String] = ["name": user!["name"], "photo_url": user!["photo_url"]] as AnyObject
                        groupName += "\(user!["name"]), "
                    }
                    
                    let groupData = ["name": groupName, "notifications": true, "users": usersData] as [String : AnyObject]
                    
                    self.FirebaseAPI.getGroupsRef().child(self.gid!).setValue(groupData)
                    self.sendMessage(message: self.messageTextView.text)
                })
            }
        }
    }
    
    func sendMessage(message: String) {
        // Push data to Firebase Database
        // FirebaseAPI.getMessagesRef().child(gid!).childByAutoId().setValue(mdata)
    }
    
    
    //MARK: Keyboard handling
    func handleKeyboardNotification(notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if (notification.name == Notification.Name.UIKeyboardWillShow) {
             dockBottomConstraint.constant = keyboardFrame.height
            if (messageTextView.textColor == UIColor.lightGray) {
                messageTextView.text = nil
                messageTextView.textColor = UIColor.black
            }
        } else {
             dockBottomConstraint.constant = 0
            if (messageTextView.text.isEmpty) {
                messageTextView.text = "Reply"
                messageTextView.textColor = UIColor.lightGray
            }
        }
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
    }


}
