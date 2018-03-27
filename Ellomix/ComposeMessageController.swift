//
//  ComposeMessageController.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/29/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Alamofire
import Soundcloud

class ComposeMessageController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser?


    @IBOutlet weak var searchUsersView: UIView!
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var followingUsers = [Dictionary<String, AnyObject>?]()
    var filteredUsers = [Dictionary<String, AnyObject>?]()
    var selected:[String:Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        tableView.dataSource = self
        tableView.delegate = self
        searchTextView.delegate = self
        nextButton.isEnabled = false
        
        let border = CALayer()
        border.frame = CGRect.init(x: 0, y: searchUsersView.frame.height, width: searchUsersView.frame.width, height: 1)
        border.backgroundColor = UIColor.lightGray.cgColor
        searchUsersView.layer.addSublayer(border)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.followingUsers.removeAll()
        retrieveFollowingUsers()
    }
    
    func retrieveFollowingUsers() {
        FirebaseAPI.getFollowingRef().child("\((currentUser?.uid)!)").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            let user = snapshot.value as? Dictionary<String, AnyObject>
            let uid = user?["uid"] as? String
            self.followingUsers.append(user)
            self.selected[uid!] = false
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "composeMessageCell", for: indexPath) as! ComposeMessageTableViewCell

        let user = filteredUsers[indexPath.row]
        let uid = user!["uid"] as? String
        cell.userNameLabel.text = user!["name"] as? String
        if (user!["photo_url"] as? String == "" || user!["photo_url"] == nil) {
            cell.userProfilePic.image = #imageLiteral(resourceName: "ellomix_logo_bw")
        } else {
            let url = user!["photo_url"]! as? String
            cell.userProfilePic.downloadedFrom(link: url!)
            cell.userProfilePic.layer.cornerRadius = cell.userProfilePic.frame.size.width / 2
            cell.userProfilePic.clipsToBounds = true
        }
        
        if (selected[uid!]!) {
            cell.userNameLabel.isEnabled = false
            cell.userProfilePic.alpha = 0.5
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.userNameLabel.isEnabled = true
            cell.userProfilePic.alpha = 1.0
            cell.backgroundColor = UIColor.white
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
        let uid = user!["uid"] as? String

        let cell = tableView.cellForRow(at: indexPath) as! ComposeMessageTableViewCell
        if (selected[uid!]!) {
            cell.userNameLabel.isEnabled = true
            cell.userProfilePic.alpha = 1.0
            cell.backgroundColor = UIColor.white
        } else {
            cell.userNameLabel.isEnabled = false
            cell.userProfilePic.alpha = 0.5
            cell.backgroundColor = UIColor.lightGray
        }
        selected[uid!] = !(selected[uid!]!)
        
        if (selected.values.contains(true)) {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    
    @IBAction func cancelNewMessage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Text View functions
    func textViewDidChange(_ textView: UITextView) {
        filterUsers(searchText: textView.text!)
        tableView.reloadData()
    }
    
    //MARK: Helpers
    func filterUsers(searchText: String) {
        filteredUsers = followingUsers.filter{ user in
            let name = user!["name"] as? String
            return (name?.lowercased().contains(searchText.lowercased()))!
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSendNewMessage") {
            let segueVC:ChatViewController = segue.destination as! ChatViewController
            
            var newChatGroup = [Dictionary<String, AnyObject>?]()
            for user in followingUsers {
                if (selected[(user!["uid"] as? String)!])! {
                    newChatGroup.append(user)
                }
            }
            segueVC.newChatGroup = newChatGroup
        }
    }
    
}
