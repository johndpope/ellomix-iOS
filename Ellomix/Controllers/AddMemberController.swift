//
//  AddMemberController.swift
//  Ellomix
//
//  Created by Kevin Avila on 7/21/18.
//  Copyright © 2018 Ellomix. All rights reserved.
//

import UIKit
import Firebase

class AddMemberController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationBarDelegate {
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchUsersView: UIView!
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var followingUsers = Dictionary<String, AnyObject>()
    var filteredUsers = [Dictionary<String, AnyObject>?]()
    var selected:[String:Bool] = [:]
    var group: Group!
    var delegate: GroupSettingsTableViewController?
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        setupNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
        searchTextView.delegate = self
        addButton.isEnabled = false
        
        searchTextView.text = "Search..."
        searchTextView.textColor = UIColor.lightGray
        
        let border = CALayer()
        border.frame = CGRect.init(x: 0, y: searchUsersView.frame.height, width: searchUsersView.frame.width, height: 1)
        border.backgroundColor = UIColor.lightGray.cgColor
        searchUsersView.layer.addSublayer(border)
        
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        retrieveUsers()
    }
    
    func setupNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            navigationBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        navigationBar.delegate = self
    }
    
    @IBAction func cancelAddMember(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        var usersToAdd = Dictionary<String, AnyObject>()
        for (uid, val) in followingUsers {
            if (selected[uid])! {
                if let newVal = val as? Dictionary<String, AnyObject> {
                    usersToAdd[uid] = newVal as AnyObject
                    FirebaseAPI.getUsersRef().child(uid).child("groups").child(group.gid!).setValue(true)
                }
            }
        }
        
        FirebaseAPI.getGroupsRef().child(group.gid!).child("users").updateChildValues(usersToAdd, withCompletionBlock: { (error:Error?, ref:DatabaseReference!) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                if (self.delegate != nil) {
                    self.group.users?.merge(usersToAdd, uniquingKeysWith: {(first, _) in first})
                    self.delegate!.group = self.group
                }
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
    func retrieveUsers() {
        FirebaseAPI.getFollowingRef().child("\((currentUser?.uid)!)").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            if let users = self.group.users {
                if (!users.keys.contains(snapshot.key)) {
                    self.followingUsers[snapshot.key] = snapshot.value as AnyObject
                    self.selected[snapshot.key] = false
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: Text View functions
    func textViewDidChange(_ textView: UITextView) {
        filterUsers(searchText: textView.text!)
        tableView.reloadData()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (searchTextView.textColor == UIColor.lightGray) {
            searchTextView.text = nil
            searchTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (searchTextView.text.isEmpty) {
            searchTextView.text = "Search..."
            searchTextView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        let user = filteredUsers[indexPath.row]
        let uid = user!["uid"] as? String
        cell.userLabel.text = user!["name"] as? String
        cell.selectionStyle = .none
        if (user!["photo_url"] as? String == "" || user!["photo_url"] == nil) {
            cell.userImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
        } else {
            let url = user!["photo_url"]! as? String
            cell.userImageView.downloadedFrom(link: url)
        }
        
        if (selected[uid!]!) {
            cell.userLabel.isEnabled = false
            cell.userImageView.alpha = 0.5
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.userLabel.isEnabled = true
            cell.userImageView.alpha = 1.0
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
        let uid = user!["uid"] as? String
        
        let cell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        if (selected[uid!]!) {
            cell.userLabel.isEnabled = true
            cell.userImageView.alpha = 1.0
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.userLabel.isEnabled = false
            cell.userImageView.alpha = 0.5
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        selected[uid!] = !(selected[uid!]!)
        
        if (selected.values.contains(true)) {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: Navigation Bar functions
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    //MARK: Helpers
    func filterUsers(searchText: String) {
        filteredUsers = followingUsers.usersArray().filter{ user in
            let name = user["name"] as? String
            return (name?.lowercased().contains(searchText.lowercased()))!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
    }
}
