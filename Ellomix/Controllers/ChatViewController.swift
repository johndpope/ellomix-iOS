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
    private var notificationService: NotificationService!
    private var messagesRefHandle: DatabaseHandle?
    private var ytService: YoutubeService!
    private var scService: SoundcloudService!
    var currentUser: EllomixUser?
    var baseDelegate: ContainerViewController!
    var group: Group?
    var currentTrackCell: MessageTableViewCell!
    var newChatGroup: [EllomixUser]?
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        notificationService = NotificationService()
        ytService = YoutubeService()
        scService = SoundcloudService()
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
        chatTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        
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
        if (newChatGroup != nil) {
            FirebaseAPI.checkForExistingGroup(uid: (currentUser?.uid)!, groupToCheck: newChatGroup!) { (existingGroup) -> () in
                if (existingGroup != nil) {
                    // We found an existing group
                    var groupTitle = ""
                    if (existingGroup!.name == nil || existingGroup!.name!.isEmpty) {
                        if let users = existingGroup!.users {
                            groupTitle = users.groupNameFromUsers() + " >"
                        }
                    } else {
                        groupTitle = existingGroup!.name! + " >"
                    }
                    self.groupNameButton.setTitle(groupTitle, for: .normal)
                    self.groupNameButton.isEnabled = true
                } else {
                    // This is a new group
                    let groupTitle = self.newChatGroup!.groupNameFromUsers() + " >"
                    self.groupNameButton.setTitle(groupTitle, for: .normal)
                    self.groupNameButton.isEnabled = false
                }
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        let type = message.type == nil ? "text" : message.type

        if (message.uid == currentUser?.uid) {
            cell.setupSentCell(type: type!)
        } else {
            cell.setupReceivedCell(type: type!)
            
            //TODO: Safely unwrap users
            for user in (self.group?.users)! {
                if (user.uid == message.uid!) {
                    cell.userImageView.downloadedFrom(link: user.profilePicLink)
                    break
                }
            }
        }
        
        if (type == "track") {
            if let track = message.track {
                cell.track = track
                cell.trackPreview.trackTitle.text = track.title
                cell.trackPreview.trackArtist.text = track.artist
                cell.trackPreview.trackThumbnail.downloadedFrom(link: track.thumbnailURL)
                
                if (track.source == "soundcloud") {
                    cell.trackPreview.serviceIcon.image = #imageLiteral(resourceName: "soundcloud")
                } else if (track.source == "youtube") {
                    cell.trackPreview.serviceIcon.image = #imageLiteral(resourceName: "youtube")
                }
                
                cell.trackPreviewButton.addTarget(self, action: #selector(playTrack(sender:)), for: .touchUpInside)
            }
        } else {
            cell.textView.text = message.content
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.messages[indexPath.row]
        let type = message.type == nil ? "text" : message.type
        
        if (type == "track") {
            return 80
        }
        
        return UITableViewAutomaticDimension
    }
    
    @objc func playTrack(sender: UIButton) {
        if let cell = sender.superview as? MessageTableViewCell {
            if let baseTrack = cell.track {
                self.baseDelegate?.playTrack(track: baseTrack)

                //TODO: Fix this logic
                if (currentTrackCell != cell) {
                    if (currentTrackCell != nil) {
                        currentTrackCell.trackPreview.play()
                    }
                    
                    if (cell.trackPreview.isPlaying()) {
                        cell.trackPreview.pause()
                    } else {
                        cell.trackPreview.play()
                    }

                    currentTrackCell = cell
                }
            }
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
                //TODO: Use FirebaseAPI function
                FirebaseAPI.getGroupsRef().childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
                    self.group = Group()
                    self.group?.gid = snapshot.key
                    self.observeMessages()
                    
                    if (self.newChatGroup != nil) {
                        for user in self.newChatGroup! {
                            self.FirebaseAPI.getUsersRef().child(user.uid).child("groups").child((self.group?.gid)!)
                                .setValue(true)
                        }
                        self.currentUser?.groups[(self.group?.gid)!] = true
                        self.group?.users = self.newChatGroup
                        self.FirebaseAPI.getGroupsRef().child((self.group?.gid)!).child("users")
                            .updateChildValues(self.newChatGroup!.userDictionaryByKey(key: "uid"))
                        self.sendMessage()
                    }
                })
            }
        }
    }
    
    func sendMessage() {
        let message = Message()

        message.timestamp = Int(Date().timeIntervalSince1970)
        message.uid = self.currentUser?.uid
        message.content = self.messageTextView.text
        message.type = "text"

        FirebaseAPI.sendMessageToGroupChat(gid: (self.group?.gid)!, message: message)
        messageTextView.text = ""

        // Send push notification
        notificationService.sendNewMessageNotification(gid: (self.group?.gid)!, sender: self.currentUser!, message: message)
    }
    
    
    //MARK: Keyboard handling
    @objc func handleKeyboardNotification(notification: Notification) {
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
