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
    var group: Group?
    var newChatGroup: [Dictionary<String, AnyObject>?]?
    
    var messages = [Message]()
    
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
        messageTextView.sizeToFit()
        
        chatTableView.estimatedRowHeight = 40
        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if (group == nil) {
            checkForExistingGroup()
        } else {
            observeMessages()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (messages.count > 0) {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        if let refHandle = messagesRefHandle {
            FirebaseAPI.getMessagesRef().child((group?.gid)!).removeObserver(withHandle: refHandle)
        }
    }
    
    func checkForExistingGroup() {
        FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let gid = child.key

                self.FirebaseAPI.getGroupsRef().child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                        if let users = dictionary["users"] as? Dictionary<String, AnyObject> {
                            let currentGroup = Array(users.keys)
                            
                            var newGroup = [String]()
                            for user in self.newChatGroup! {
                                newGroup.append(user!["uid"] as! String)
                            }
                            
                            if (Set(currentGroup) == Set(newGroup)) {
                                self.group = Group()
                                self.group?.gid = gid
                                self.group?.users = self.newChatGroup
                                self.observeMessages()
                            }
                            
                            let groupName = dictionary["name"] as? String
                            if (groupName == nil || (groupName?.isEmpty)!) {
                                self.navigationItem.title = self.newChatGroup?.groupNameFromUsers()
                            } else {
                                self.navigationItem.title = groupName
                            }
                        }
                    }
                })
            }
        })
    }

    func observeMessages() {
        messagesRefHandle = FirebaseAPI.getMessagesRef().child((group?.gid)!).observe(.childAdded, with: { (snapshot)  in
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                let message = Message()
                message.uid = dictionary["uid"] as? String
                message.content = dictionary["content"] as? String
                message.timestamp = dictionary["timestamp"] as? Int
                self.messages.append(message)

                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //Mark: Table View functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]

        if (message.uid == currentUser?.uid) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sentMessageCell", for: indexPath) as! SentChatTableViewCell
            cell.messageTextView.layer.cornerRadius = 8.0
            cell.messageTextView.text = message.content!

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! RecievedChatTableViewCell
            cell.messageTextView.layer.cornerRadius = 8.0
            cell.messageTextView.text = message.content!
            for user in (self.group?.users)! {
                let uid = user!["uid"] as? String
                if (uid! == message.uid!) {
                    if let photoURL = user!["photo_url"] as? String, !photoURL.isEmpty {
                        cell.profilePic.downloadedFrom(link: photoURL)
                    } else {
                        cell.profilePic.image = #imageLiteral(resourceName: "ellomix_logo_bw")
                    }
                    break
                }
            }

            return cell
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        if (!messageTextView.text.isEmpty) {
            if (group != nil) {
                sendMessage()
            } else {
                FirebaseAPI.getGroupsRef().childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
                    self.group = Group()
                    self.group?.gid = snapshot.key
                    self.observeMessages()
                    
                    var usersData = [String: AnyObject]()
                    for user in self.newChatGroup! {
                        let uid = user!["uid"] as? String
                        usersData[uid!] = ["name": user!["name"], "photo_url": user!["photo_url"]] as AnyObject
                        self.FirebaseAPI.getUsersRef().child(uid!).child("groups").child((self.group?.gid)!).setValue(true)
                    }
                    self.currentUser?.groups.append((self.group?.gid)!)
                    self.group?.users = self.newChatGroup
                    let groupValues = ["notifications": true, "users": usersData] as [String : AnyObject]
                    
                    self.FirebaseAPI.getGroupsRef().child((self.group?.gid)!).updateChildValues(groupValues)
                    self.sendMessage()
                })
            }
        }
    }
    
    func sendMessage() {
        let timestamp:Int = Int(Date().timeIntervalSince1970)
        let messageValues = ["uid": self.currentUser?.uid, "content": self.messageTextView.text, "timestamp": timestamp] as [String : AnyObject]
        self.FirebaseAPI.getMessagesRef().child((self.group?.gid)!).childByAutoId().updateChildValues(messageValues)
        self.FirebaseAPI.getGroupsRef().child((self.group?.gid)!).child("last_message").updateChildValues(messageValues)
        messageTextView.text = ""
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
            self.chatTableView.contentOffset.y -= keyboardFrame.height
            if (messageTextView.text.isEmpty) {
                messageTextView.text = "Reply"
                messageTextView.textColor = UIColor.lightGray
            }
        }
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            if (notification.name == Notification.Name.UIKeyboardWillShow) {
                self.chatTableView.contentOffset.y += keyboardFrame.height
            }
        }, completion: nil)
    }
    
    //MARK: TextView functions
    
    func textViewDidChange(_ textView: UITextView) {
        if messageTextView.contentSize.height >= 100 {
            messageTextView.isScrollEnabled = true
        } else {
            messageTextView.frame.size.height = messageTextView.contentSize.height
            messageTextView.isScrollEnabled = false
        }
    }


}
