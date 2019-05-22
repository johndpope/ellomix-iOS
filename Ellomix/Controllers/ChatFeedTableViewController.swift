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
        var groupChatDictionary = Dictionary<String, Group>()
        var removeIndices = [Int]()

        for i in 0..<groupChats.count {
            let group = groupChats[i]
            if (!(group.users!.keys.contains(currentUser!.uid))) {
                removeIndices.append(i)
            } else {
                groupChatDictionary[group.gid!] = group
            }
        }
        for index in removeIndices {
            groupChats.remove(at: index)
        }
        
        let currentGIDs = Array(groupChatDictionary.keys)
        for gid in (self.currentUser?.groups.keys)! {
            if (!currentGIDs.contains(gid)) {
                let group = Group()
                group.gid = gid
                observeChat(group: group)
                self.groupChats.append(group)
            } else {
                observeChat(group: groupChatDictionary[gid]!)
            }
        }
        
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
                let group = Group()
                group.gid = gid
                self.observeChat(group: group)
                self.currentUser?.groups[gid] = notifications
                self.groupChats.append(group)
            }
        })

    }
    
    func observeChat(group: Group) {
        let handle = FirebaseAPI.getGroupsRef().child(group.gid!).observe(.value, with: { (snapshot) in
            if let groupDictionary = snapshot.value as? Dictionary<String, AnyObject> {
                self.setGroupProperties(group: group, groupDictionary: groupDictionary)
                DispatchQueue.main.async {
                    self.groupChats.sort() {
                        if let message0 = $0.lastMessage, let message1 = $1.lastMessage {
                            if let timestamp0 = message0.timestamp, let timestamp1 = message1.timestamp {
                                return timestamp0 > timestamp1
                            }
                        }
                        return false
                    }
                    self.tableView.reloadData()
                }
            }
        })
        
        currentChatObservers[group.gid!] = handle
    }
    
    func setGroupProperties(group: Group, groupDictionary: Dictionary<String, AnyObject>) {
        group.name = groupDictionary["name"] as? String
        if let users = groupDictionary["users"] as? Dictionary<String, AnyObject> {
            group.users = users
        }
        
        let lastMessage = Message()
        if let lastMessageDictionary = groupDictionary["last_message"] as? Dictionary<String, AnyObject> {
            lastMessage.content = lastMessageDictionary["content"] as? String
            lastMessage.timestamp = lastMessageDictionary["timestamp"] as? Int
            group.lastMessage = lastMessage
        }
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
        var users = [Dictionary<String, AnyObject>]()
        
        // Make a new dictionary of users that excludes our user
        //TODO: Change users property of group to an array of Ellomix users
        if (group.users != nil) {
            var otherUsers = group.users!
            otherUsers.removeValue(forKey: (currentUser?.uid)!)
            users = otherUsers.usersArray()
        }
        
        if (users.count == 1) {
            let user = users[0]
            if let photoURL = user["photo_url"] as? String, !photoURL.isEmpty {
                cell.profileImageView.downloadedFrom(link: photoURL)
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
            cell.profileImageView.circular()
        } else if (users.count > 1) {
            let firstUser = users[0]
            let secondUser = users[1]
            
            if let photoURL = firstUser["photo_url"] as? String, !photoURL.isEmpty {
                cell.profileImageView.image = nil
                cell.firstProfileImageView.downloadedFrom(link: photoURL)
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
            
            if let photoURL = secondUser["photo_url"] as? String, !photoURL.isEmpty {
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
            if let newChatGroup = sender as? Dictionary<String, AnyObject>? {
                segueVC.newChatGroup = newChatGroup
            }
        }
    }
 

}
