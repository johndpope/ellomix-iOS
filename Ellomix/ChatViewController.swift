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
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if (gid == nil) {
            checkForExistingGroup()
        } else {
            observeMessages()
        }
    }
    
    deinit {
        if let refHandle = messagesRefHandle {
            FirebaseAPI.getMessagesRef().child(gid!).removeObserver(withHandle: refHandle)
        }
    }
    
    func checkForExistingGroup() {
        FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let gid = child.key

                self.FirebaseAPI.getGroupsRef().child(gid).child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                    var currentGroup = [String]()
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        currentGroup.append(child.key)
                    }
                    
                    var newGroup = [String]()
                    for user in self.newChatGroup! {
                        newGroup.append(user!["uid"] as! String)
                    }
                    
                    if (currentGroup == newGroup) {
                        self.gid = gid
                        self.observeMessages()
                    }
                })
            }
        })
    }

    func observeMessages() {
        messagesRefHandle = FirebaseAPI.getMessagesRef().child(gid!).observe(.childAdded, with: { (snapshot)  in
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                let message = Message()
//                message.setValuesForKeys(dictionary)
//                self.messages.append(message)
//
//                DispatchQueue.main.async {
//                    self.chatTableView.reloadData()
//                }
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
            cell.messageTextView.text = message.content as! String
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! RecievedChatTableViewCell
            cell.messageTextView.text = message.content as! String
            return cell
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        if (!messageTextView.text.isEmpty) {
            if (gid != nil) {
                sendMessage()
            } else {
                FirebaseAPI.getGroupsRef().childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
                    self.gid = snapshot.key
                    self.observeMessages()
                    
                    var groupName = ""
                    var usersData = [String: AnyObject]()
                    for user in self.newChatGroup! {
                        usersData[user!["uid"] as! String] = ["name": user!["name"], "photo_url": user!["photo_url"]] as AnyObject
                        groupName += "\(user!["name"]!), "
                    }
                    
                    let groupValues = ["name": groupName, "notifications": true, "users": usersData] as [String : AnyObject]
                    
                    self.FirebaseAPI.getGroupsRef().child(self.gid!).updateChildValues(groupValues)
                    self.sendMessage()
                })
            }
        }
    }
    
    func sendMessage() {
        let timestamp:Int = Int(Date.timeIntervalSinceReferenceDate)
        let messageValues = ["uid": self.currentUser?.uid, "content": self.messageTextView.text, "timestamp": timestamp] as [String : AnyObject]
        self.FirebaseAPI.getMessagesRef().child(self.gid!).childByAutoId().updateChildValues(messageValues)
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
