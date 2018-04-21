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

    var currentUser:EllomixUser?
    
    var groupChats = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        currentUser = Global.sharedGlobal.user
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var groupChatDictionary = Dictionary<String, Group>()
        for group in groupChats {
            groupChatDictionary[group.gid!] = group
        }
        let currentGIDs = Array(groupChatDictionary.keys)

        for gid in (self.currentUser?.groups)! {
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

            if (!(self.currentUser?.groups.contains(gid))!) {
                let group = Group()
                group.gid = gid
                self.observeChat(group: group)
                self.currentUser?.groups.append(gid)
                self.groupChats.append(group)
            }
        })

    }
    
    func observeChat(group: Group) {
        let handle = FirebaseAPI.getGroupsRef().child(group.gid!).observe(.value, with: { (snapshot) in
            if let groupDictionary = snapshot.value as? Dictionary<String, AnyObject> {
                self.setGroupProperties(group: group, groupDictionary: groupDictionary)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        
        currentChatObservers[group.gid!] = handle
    }
    
    func setGroupProperties(group: Group, groupDictionary: Dictionary<String, AnyObject>) {
        group.name = groupDictionary["name"] as? String
        group.notifications = groupDictionary["notifications"] as? Bool
        if let users = groupDictionary["users"] as? Dictionary<String, AnyObject> {
            var usersArray = [Dictionary<String, AnyObject>?]()
            for user in users.values {
                usersArray.append(user as? Dictionary<String, AnyObject>)
            }
            group.users = usersArray
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
        
        if (group.name == nil || group.name!.isEmpty) {
            cell.chatNameLabel.text = group.users?.groupNameFromUsers()
        } else {
           cell.chatNameLabel.text = group.name!
        }
        
        if let seconds = group.lastMessage?.timestamp {
            let timestampDate = Date(timeIntervalSinceReferenceDate: Double(seconds))
            cell.timestampLabel.text = timestampDate.timeAgoDisplay()
        }
        cell.profileImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
        cell.recentMessageLabel.text = group.lastMessage?.content
        cell.gid = group.gid!

        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toChatDetail") {
            let segueVC = segue.destination as! ChatViewController
            let cell = self.tableView.cellForRow(at: (self.tableView.indexPathForSelectedRow)!) as! ChatFeedTableViewCell
            segueVC.gid = cell.gid
            segueVC.navigationItem.title = cell.chatNameLabel.text
        } else if (segue.identifier == "toComposeModal") {
            let segueVC = segue.destination as! ComposeMessageController
            segueVC.chatFeedDelegate = self
        } else if (segue.identifier == "toSendNewMessage") {
            let segueVC = segue.destination as! ChatViewController
            if let newChatGroup = sender as? [Dictionary<String, AnyObject>?] {
                segueVC.newChatGroup = newChatGroup
            }
        }
    }
 

}
