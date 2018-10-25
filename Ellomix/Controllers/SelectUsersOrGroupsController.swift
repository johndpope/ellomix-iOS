//
//  SelectUsersOrGroupsController.swift
//  Ellomix
//
//  Created by Kevin Avila on 9/28/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SelectUsersOrGroupsController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var sendButton: UIBarButtonItem!

    var groupsAndFollowingUsers = [AnyObject]()
    var filteredGroupsAndFollowingUsers = [AnyObject]()
    var selected:[String:AnyObject] = [:]
    let searchController = UISearchController(searchResultsController: nil)
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser?
    var currentTrack: Any!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true

        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.register(UINib(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "groupCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sendButton.isEnabled = false
        groupsAndFollowingUsers.removeAll()
        filteredGroupsAndFollowingUsers.removeAll()
        selected.removeAll()
        retrieveGroupsAndUsers()
    }

    @IBAction func dismissButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        let selectedUserOrGroup = selected.first?.value
        let message = Message()
        let track = BaseTrack()
        
        message.uid = currentUser?.uid
        message.type = "track"
        message.timestamp = Int(Date().timeIntervalSince1970)
        
        //TODO: Make currentTrack a BaseTrack type to get rid of switch statement
        switch currentTrack {
        case is SoundcloudTrack:
            let scTrack = currentTrack as! SoundcloudTrack
            track.id = scTrack.id
            track.title = scTrack.title
            track.artist = scTrack.artist
            track.thumbnailURL = String(describing: scTrack.thumbnailURL!)
            track.source = "soundcloud"
        case is YouTubeVideo:
            let ytTrack = currentTrack as! YouTubeVideo
            track.id = ytTrack.videoID
            track.title = ytTrack.videoTitle
            track.artist = ytTrack.videoChannel
            track.thumbnailURL = ytTrack.videoThumbnailURL
            track.source = "youtube"
        default:
            print("Unable to share track.")
        }
        
        message.track = track
        
        if (selectedUserOrGroup is EllomixUser) {
            //TODO: Make firebase method that checks for existing groups/creates a new one to send the song too
        } else {
            let group = selectedUserOrGroup as! Group
            
            FirebaseAPI.sendMessageToGroupChat(group: group, message: message)
        }
        
        let alertTitle = "Shared song"
        let alertMessage = "Shared song to group chat!"
        EllomixAlertController.showAlert(viewController: self, title: alertTitle, message: alertMessage, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func retrieveGroupsAndUsers() {
        FirebaseAPI.getFollowingRef().child("\((currentUser?.uid)!)").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            var userDict = snapshot.value as? Dictionary<String, AnyObject>
            userDict!["uid"] = snapshot.key as AnyObject
            if let ellomixUser = userDict!.toEllomixUser() {
                self.groupsAndFollowingUsers.append(ellomixUser)
                self.filteredGroupsAndFollowingUsers.append(ellomixUser)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        for gid in (currentUser?.groups)! {
            FirebaseAPI.getGroupsRef().child(gid).observe(.value, with: { (snapshot) in
                var groupDict = snapshot.value as? Dictionary<String, AnyObject>
                groupDict!["gid"] = snapshot.key as AnyObject
                if let group = groupDict?.toGroup() {
                    if (group.users != nil && group.users!.count > 2)  {
                        self.groupsAndFollowingUsers.append(group)
                        self.filteredGroupsAndFollowingUsers.append(group)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        //TODO: Non-group message, match it with the user so we can prioritize it in the table
                    }
                }
            }) { (error) in
               print(error.localizedDescription)
            }
        }
    }
    
    //Mark: Table View functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroupsAndFollowingUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userOrGroup = filteredGroupsAndFollowingUsers[indexPath.row]
        let shouldBeDisabled = cellShouldBeDisabled(userOrGroup: userOrGroup)
        
        if (userOrGroup is EllomixUser) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            let ellomixUser = userOrGroup as! EllomixUser
            
            cell.selectionStyle = .none
            cell.userLabel.text = ellomixUser.getName()
            if (!ellomixUser.profilePicLink.isEmpty) {
                cell.userImageView.downloadedFrom(link: ellomixUser.profilePicLink)
            } else {
                cell.userImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
            
            if (shouldBeDisabled) {
                cell.userLabel.isEnabled = false
                cell.userImageView.alpha = 0.5
            } else {
                cell.userLabel.isEnabled = true
                cell.userImageView.alpha = 1.0
                if (selected[ellomixUser.uid] != nil) {
                    // User is selected
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    // User is not selected
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell
            let group = userOrGroup as! Group
            
            if (group.users != nil) {
                // Make a new array of users that excludes our user
                //TODO: Change users property of group to an array of Ellomix users
                var users = [EllomixUser]()
                for user in group.users! {
                    if (user.key != (currentUser?.uid)!) {
                        var userDict = user.value as? Dictionary<String, AnyObject>
                        userDict!["uid"] = user.key as AnyObject
                        if let ellomixUser = userDict!.toEllomixUser() {
                            users.append(ellomixUser)
                        }
                    }
                }
                
                let firstUser = users[0]
                let secondUser = users[1]
                
                cell.selectionStyle = .none
                if (!firstUser.profilePicLink.isEmpty) {
                    cell.bottomLeftImageView.downloadedFrom(link: firstUser.profilePicLink)
                } else {
                    cell.bottomLeftImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
                }
                
                if (!secondUser.profilePicLink.isEmpty) {
                    cell.topRightImageView.downloadedFrom(link: secondUser.profilePicLink)
                } else {
                    cell.topRightImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
                }
                
                if (users.count > 2) {
                    let additionalUsersCount = users.count - 2
                    cell.numberLabel.text = "+\(additionalUsersCount)"
                    cell.numberLabel.circular()
                    cell.numberLabel.isHidden = false
                    let widthDifference = cell.imageContainerView.frame.size.width - cell.topRightImageView.frame.size.width
                    cell.topRightImageLeadingConstraint.constant -= (widthDifference / 2)
                }
                
                if (group.name == nil || group.name!.isEmpty) {
                    cell.groupNameLabel.text = group.users?.groupNameFromUsers()
                } else {
                    cell.groupNameLabel.text = group.name!
                }
                
                if (shouldBeDisabled) {
                    cell.groupNameLabel.isEnabled = false
                    cell.bottomLeftImageView.alpha = 0.5
                    cell.topRightImageView.alpha = 0.5
                    cell.numberLabel.isEnabled = false
                } else {
                    cell.groupNameLabel.isEnabled = true
                    cell.bottomLeftImageView.alpha = 1.0
                    cell.topRightImageView.alpha = 1.0
                    cell.numberLabel.isEnabled = true
                    if (selected[group.gid!] != nil) {
                        // Group is selected
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    } else {
                        // Group is not selected
                        cell.accessoryType = UITableViewCellAccessoryType.none
                    }
                }
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell: UITableViewCell!
        var id: String!
        let userOrGroup = filteredGroupsAndFollowingUsers[indexPath.row]

        if (userOrGroup is EllomixUser) {
            let ellomixUser = userOrGroup as! EllomixUser
            id = ellomixUser.uid
            cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        } else {
            let group = userOrGroup as! Group
            id = group.gid!
            cell = tableView.cellForRow(at: indexPath) as! GroupTableViewCell
        }

        if (selected[id] != nil) {
            // This user/group is already selected
            cell.accessoryType = UITableViewCellAccessoryType.none
            selected.removeValue(forKey: id)
        } else {
            // This user/group hasn't been selected
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            selected[id] = userOrGroup
        }
        
        if (selected.isEmpty) {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
        
        // Reload data to disable appropriate cells
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let userOrGroup = filteredGroupsAndFollowingUsers[indexPath.row]
        
        if (cellShouldBeDisabled(userOrGroup: userOrGroup)) {
            return nil
        }
        
        return indexPath
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: Searchbar
    func updateSearchResults(for searchController: UISearchController) {
        if (!(searchController.searchBar.text!.isEmpty)) {
            filterGroupsAndUsers(searchText: searchController.searchBar.text!)
        } else {
            filteredGroupsAndFollowingUsers = groupsAndFollowingUsers
        }

        tableView.reloadData()
    }
    
    //MARK: Helpers
    func filterGroupsAndUsers(searchText: String) {
        filteredGroupsAndFollowingUsers = groupsAndFollowingUsers.filter { groupOrUser in
            var name = ""
            if (groupOrUser is EllomixUser) {
                let user = groupOrUser as! EllomixUser
                name = user.getName()
            } else {
                // Parse group name
                let group = groupOrUser as! Group
                if (group.name == nil || group.name!.isEmpty) {
                    name = (group.users?.groupNameFromUsers())!
                } else {
                    name = group.name!
                }
            }
            
            return name.lowercased().contains(searchText.lowercased())
        }
    }
    
    func cellShouldBeDisabled(userOrGroup: AnyObject) -> Bool {
        if (!selected.isEmpty) {
            let selectedUserOrGroup = selected.first?.value
            
            if (selectedUserOrGroup is EllomixUser) {
                if (userOrGroup is Group) {
                    return true
                }
            } else {
                let selectedGroup = selectedUserOrGroup as! Group
                
                if (userOrGroup is EllomixUser) {
                    return true
                } else if ((userOrGroup as! Group).gid! != selectedGroup.gid!) {
                    return true
                }
            }
        }
        
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
    }
}
