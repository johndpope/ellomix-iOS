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
    
    private var groupsRefHandle: DatabaseHandle?
    private var FirebaseAPI: FirebaseApi!

    var currentUser:EllomixUser?
    
    var groupChats = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        currentUser = Global.sharedGlobal.user
        observeChats()
    }
    
    deinit {
        if let refHandle = groupsRefHandle  {
            FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").removeObserver(withHandle: refHandle)
        }
    }
    
    func observeChats() {
        groupsRefHandle = FirebaseAPI.getUsersRef().child((currentUser?.uid)!).child("groups").observe(.childAdded, with: { (snapshot) -> Void in
            let gid = snapshot.key

            self.FirebaseAPI.getGroupsRef().child(gid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let groupDictionary = snapshot.value as? Dictionary<String, AnyObject> {
                    let group = Group()
                    group.gid = gid
                    group.name = groupDictionary["name"] as? String
                    group.notifications = groupDictionary["notifications"] as? Bool
                    
                    let lastMessage = Message()
                    if let lastMessageDictionary = groupDictionary["last_message"] as? Dictionary<String, AnyObject> {
                        lastMessage.content = lastMessageDictionary["content"] as? String
                        lastMessage.timestamp = lastMessageDictionary["timestamp"] as? Int
                        group.lastMessage = lastMessage
                    }
                    self.groupChats.append(group)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })

        })

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
            tableView.separatorStyle  = .none
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
            // Make an extension
            cell.chatNameLabel.text = "Group Name"
        } else {
           cell.chatNameLabel.text = group.name!
        }

        cell.recentMessageLabel.text = group.lastMessage?.content
        cell.gid = group.gid!

        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toChatDetail") {
            let segueVC: ChatViewController = segue.destination as! ChatViewController
            let cell: ChatFeedTableViewCell = self.tableView.cellForRow(at: (self.tableView.indexPathForSelectedRow)!) as! ChatFeedTableViewCell
            segueVC.gid = cell.gid
        }
    }
 

}
