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
    @IBOutlet weak var groupNameButton: UIButton!
    @IBOutlet weak var dockBottomConstraint: NSLayoutConstraint!

    private var FirebaseAPI: FirebaseApi!
    private var messagesRefHandle: DatabaseHandle?
    var currentUser: EllomixUser?
    var baseDelegate: ContainerViewController!
    var group: Group?
    var newChatGroup: Dictionary<String, AnyObject>?
    
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
        
        if (group == nil) {
            checkForExistingGroup()
        } else {
            setChatTitle()
            observeMessages()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (group != nil) {
            setChatTitle()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if (messages.count > 0) {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if let refHandle = messagesRefHandle {
            FirebaseAPI.getMessagesRef().child((group?.gid)!).removeObserver(withHandle: refHandle)
        }
    }
    
    func setChatTitle() {
        if (group!.name == nil || group!.name!.isEmpty) {
            if let users = group!.users {
                let groupTitle = users.groupNameFromUsers() + " >"
                groupNameButton.setTitle(groupTitle, for: .normal)
            }
        } else {
            groupNameButton.setTitle(group!.name! + " >", for: .normal)
        }
    }
    
    func checkForExistingGroup() {
        FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            var foundGroup = false
            var counter = 0
            let groupCount = snapshot.childrenCount
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let gid = child.key

                self.FirebaseAPI.getGroupsRef().child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                        if let users = dictionary["users"] as? Dictionary<String, AnyObject> {
                            let currentGroup = Array(users.keys)
                            let newGroup = Array(self.newChatGroup!.keys)
                            
                            if (Set(currentGroup) == Set(newGroup)) {
                                foundGroup = true
                                self.group = Group()
                                self.group?.gid = gid
                                self.group?.users = self.newChatGroup
                                self.observeMessages()
                            }

                            if (foundGroup) {
                                let groupName = dictionary["name"] as? String
                                var groupTitle = ""
                                if (groupName == nil || (groupName?.isEmpty)!) {
                                    groupTitle = (self.newChatGroup?.groupNameFromUsers())! + " >"
                                } else {
                                    groupTitle = groupName! + " >"
                                }
                                self.groupNameButton.setTitle(groupTitle, for: .normal)
                                self.groupNameButton.isEnabled = true
                            } else if (counter == (groupCount - 1)) {
                                let groupTitle = self.newChatGroup?.groupNameFromUsers()
                                self.groupNameButton.setTitle(groupTitle, for: .normal)
                                self.groupNameButton.isEnabled = false
                            }
                            counter+=1
                        }
                    }
                })
            }
        })
    }

    func observeMessages() {
        messagesRefHandle = FirebaseAPI.getMessagesRef().child((group?.gid)!).observe(.childAdded, with: { (snapshot)  in
            if let messageDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let message = messageDict.toMessage() {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.chatTableView.reloadData()
                    }
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
            cell.messageTextView.text = message.content

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! RecievedChatTableViewCell
            cell.messageTextView.layer.cornerRadius = 8.0
            cell.messageTextView.text = message.content
            for (uid, val) in (self.group?.users)! {
                if (uid == message.uid!) {
                    if let photoURL = val["photo_url"] as? String, !photoURL.isEmpty {
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
    
    @IBAction func groupNameButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toGroupSettings", sender: self)
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
                    
                    var usersData = Dictionary<String, AnyObject>()
                    for (uid, val) in self.newChatGroup! {
                        if var newVal = val as? Dictionary<String, AnyObject> {
                            newVal["notifications"] = true as AnyObject
                            usersData[uid] = newVal as AnyObject
                            self.FirebaseAPI.getUsersRef().child(uid).child("groups").child((self.group?.gid)!).setValue(true)
                        }
                    }
                    self.currentUser?.groups.append((self.group?.gid)!)
                    self.group?.users = self.newChatGroup
                    
                    self.FirebaseAPI.getGroupsRef().child((self.group?.gid)!).child("users").updateChildValues(usersData)
                    self.sendMessage()
                })
            }
        }
    }
    
    func sendMessage() {
        let timestamp:Int = Int(Date().timeIntervalSince1970)
        let messageValues = [
                "uid": self.currentUser?.uid,
                "content": self.messageTextView.text,
                "timestamp": timestamp
            ] as [String : AnyObject]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toGroupSettings") {
            let segueVC = segue.destination as! GroupSettingsTableViewController
            segueVC.baseDelegate = baseDelegate
            segueVC.delegate = self
            if let groupInfo = group {
                if let groupTitle = groupNameButton.titleLabel?.text {
                    segueVC.navigationItem.title = String(describing: groupTitle.dropLast(2))
                }
                segueVC.group = groupInfo
            }
        } else if (segue.identifier == "toGroupPlaylist") {
            let segueVC = segue.destination as! GroupPlaylistTableViewController
            segueVC.baseDelegate = baseDelegate
            if let groupInfo = group {
                segueVC.group = groupInfo
            }
        }
    }

}
