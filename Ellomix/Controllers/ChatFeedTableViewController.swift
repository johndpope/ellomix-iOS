//
//  ChatFeedTableViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/16/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class ChatFeedTableViewController: UITableViewController {
    
    private var userGroupsRefHandle: DatabaseHandle?
    private var currentChatObservers = Dictionary<String, DatabaseHandle>()
    private var FirebaseAPI: FirebaseApi!

    var currentUser: EllomixUser?
    var baseDelegate: ContainerViewController!
    
    var groupChats = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        currentUser = Global.sharedGlobal.user
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseAPI.getUserGroups(user: currentUser!, completion: { (groups) in
            self.groupChats = groups
            self.sortGroupChats()
            self.tableView.reloadData()
            
            for group in self.groupChats {
                self.observeRecentMessages(gid: group.gid!)
            }
        })
        
        observeNewChats()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let refHandle = userGroupsRefHandle  {
            FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").removeObserver(withHandle: refHandle)
        }
        
        for (gid, handle) in currentChatObservers {
            FirebaseAPI.getGroupsRef().child(gid).removeObserver(withHandle: handle)
        }
        currentChatObservers = [:]
    }
    
    func observeNewChats() {
        userGroupsRefHandle = FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").observe(.childAdded, with: { (snapshot) -> Void in
            let gid = snapshot.key
            let notifications = snapshot.value as? Bool
 
            if (!(self.currentUser?.groups.keys.contains(gid))!) {
                self.currentUser?.groups[gid] = notifications
                self.FirebaseAPI.getGroup(gid: gid, completion: { (group) in
                    self.groupChats.append(group)
                    self.sortGroupChats()
                    self.tableView.reloadData()
                    self.observeRecentMessages(gid: gid)
                })
            }
        })
    }
    
    func observeRecentMessages(gid: String) {
        let handle = FirebaseAPI.getGroupsRef().child(gid).observe(.childChanged, with: { (snapshot) in
            if let lastMessageDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let lastMessage = lastMessageDict.toMessage() {
                    for group in self.groupChats {
                        if (group.gid! == gid) {
                            group.lastMessage = lastMessage
                            self.sortGroupChats()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
        
        currentChatObservers[gid] = handle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (groupChats.count == 0) {
            let noChatsLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noChatsLabel.text = "You don't have any messages yet."
            noChatsLabel.textAlignment = .center
            tableView.backgroundView  = noChatsLabel
        } else {
            tableView.backgroundView = nil
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupChats.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ChatFeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatFeedTableViewCell
        let group = groupChats[indexPath.row]
        var users = [EllomixUser]()
        
        // Make a new group of users that excludes our user
        if (group.users != nil) {
            let otherGroup = group
            otherGroup.removeUser(uid: (currentUser?.uid)!)
            users = otherGroup.users!
        }
        
        if (users.count == 1) {
            let user = users[0]
            if let photoURL = user.profilePicLink {
                cell.profileImageView.downloadedFrom(link: photoURL)
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
            cell.profileImageView.circular()
        } else if (users.count > 1) {
            let firstUser = users[0]
            let secondUser = users[1]
            
            if let photoURL = firstUser.profilePicLink {
                cell.profileImageView.image = nil
                cell.firstProfileImageView.downloadedFrom(link: photoURL)
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
            
            if let photoURL = secondUser.profilePicLink {
                cell.profileImageView.image = nil
                cell.secondProfileImageView.downloadedFrom(link: photoURL)
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
            
            cell.firstProfileImageView.circular()
            cell.secondProfileImageView.circular()
            
            if (users.count > 2) {
                let additionalUsersCount = users.count - 2
                cell.profileImageLabel.text = "+\(additionalUsersCount)"
                cell.profileImageLabel.circular()
                cell.profileImageLabel.isHidden = false
                let widthDifference = cell.profileImageView.frame.size.width - cell.secondProfileImageView.frame.size.width
                cell.secondProfileImageLeadingConstraint.constant -= (widthDifference / 2)
            }
        }
        
        if (group.name == nil || group.name!.isEmpty) {
            cell.chatNameLabel.text = group.users?.groupNameFromUsers()
        } else {
            cell.chatNameLabel.text = group.name!
        }
        
        if let seconds = group.lastMessage?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(seconds))
            cell.timestampLabel.text = timestampDate.timeAgoDisplay()
        }
        cell.recentMessageLabel.text = group.lastMessage?.content
        cell.gid = group.gid!

        return cell
    }
    
    func sortGroupChats() {
        self.groupChats.sort() {
            if let message0 = $0.lastMessage, let message1 = $1.lastMessage {
                if let timestamp0 = message0.timestamp, let timestamp1 = message1.timestamp {
                    return timestamp0 > timestamp1
                }
            }
            return false
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toChatDetail") {
            let segueVC = segue.destination as! ChatViewController
            segueVC.baseDelegate = baseDelegate
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let group = groupChats[indexPath.row]
                segueVC.group = group
            }
        } else if (segue.identifier == "toComposeModal") {
            let segueVC = segue.destination as! ComposeMessageController
            segueVC.chatFeedDelegate = self
        } else if (segue.identifier == "toSendNewMessage") {
            let segueVC = segue.destination as! ChatViewController
            if let newChatGroup = sender as? [EllomixUser] {
                segueVC.newChatGroup = newChatGroup
            }
        }
    }
 

}
